# == Schema Information
#
# Table name: documents
#
#  id                                      :integer          not null, primary key
#  claim_id                                :integer
#  created_at                              :datetime
#  updated_at                              :datetime
#  document_file_name                      :string
#  document_content_type                   :string
#  document_file_size                      :integer
#  document_updated_at                     :datetime
#  external_user_id                        :integer
#  converted_preview_document_file_name    :string
#  converted_preview_document_content_type :string
#  converted_preview_document_file_size    :integer
#  converted_preview_document_updated_at   :datetime
#  uuid                                    :uuid
#  form_id                                 :string
#  creator_id                              :integer
#  verified_file_size                      :integer
#  file_path                               :string
#  verified                                :boolean          default(FALSE)
#

require 'rails_helper'
require 'fileutils'

TEMPFILE_NAME = File.join(Rails.root, 'tmp', 'document_spec', 'test.txt')

RSpec.describe Document, type: :model do
  it { should belong_to(:external_user) }
  it { should belong_to(:creator).class_name('ExternalUser') }
  it { should belong_to(:claim) }
  it { should delegate_method(:provider_id).to(:external_user) }

  it { is_expected.to have_one_attached :document }
  it { is_expected.to validate_presence_of :document }

  it { is_expected.to have_one_attached :converted_preview_document }
  it { is_expected.to validate_content_type_of(:converted_preview_document).allowing('application/pdf') }

  it_behaves_like 'an s3 bucket'

  it do
    is_expected.to validate_content_type_of(:document).allowing(
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.oasis.opendocument.text',
      'text/rtf',
      'application/rtf',
      'image/jpeg',
      'image/png',
      'image/tiff',
      'image/bmp',
      'image/x-bitmap'
    )
  end

  it { is_expected.to validate_size_of(:document).less_than_or_equal_to(20.megabytes) }

  context 'validation' do
    let(:claim) { create :claim }
    let(:document) { create :document, claim: claim }

    context 'total number of documents for this form_id' do
      it 'validates that the total number of documents for this claim has not been exceeded' do
        allow(Settings).to receive(:max_document_upload_count).and_return(2)
        create :document, claim_id: claim.id, form_id: claim.form_id
        create :document, claim_id: claim.id, form_id: claim.form_id

        doc = build :document, claim_id: claim.id, form_id: claim.form_id
        expect(doc).not_to be_valid
        expect(doc.errors[:document]).to eq(['Total documents exceed maximum of 2. This document has not been uploaded.'])
      end
    end

    context 'cryptic error message is deciphered' do
      it 'calls transform_cryptic_paperclip_error every time it is unable to save' do
        expect(document).to receive(:save).and_return(false)
        expect(document).to receive(:transform_cryptic_paperclip_error)
        document.save_and_verify
      end

      it 'displays human-understandable error message' do
        document.errors[:document] << 'has contents that are not what they are reported to be'
        document.__send__(:transform_cryptic_paperclip_error)
        expect(document.errors[:document]).to eq(['The contents of the file do not match the file extension'])
      end
    end
  end

  describe '#converted_preview_document' do
    subject(:preview_document) { document.converted_preview_document }

    let(:document) { create :document, document: file }

    context 'with a pdf document' do
      let(:file) do
        Rack::Test::UploadedFile.new(
          File.expand_path('features/examples/longer_lorem.pdf', Rails.root),
          'application/pdf'
        )
      end

      it 'is identical to #document' do
        expect(preview_document.checksum).to eq document.document.checksum
      end
    end

    context 'with a docx document' do
      let(:file) do
        Rack::Test::UploadedFile.new(
          File.expand_path('features/examples/shorter_lorem.docx', Rails.root),
          'application/msword'
        )
      end

      it 'is different from #document' do
        expect(preview_document.checksum).not_to eq document.document.checksum
      end

      it 'is a PDF file' do
        expect(preview_document.content_type).to eq 'application/pdf'
      end

      it 'is named after the original file' do
        expect(preview_document.filename.to_s).to eq 'shorter_lorem.docx.pdf'
      end
    end
  end

  context '#convert_and_assign_document' do
    subject { build(:document, :docx, document_content_type: 'application/msword') }

    it 'depends on the Libreconv gem' do
      expect(Libreconv).to receive(:convert)
      subject.save!
    end

    it 'handles IOError when Libreconv is not in PATH' do
      allow(Libreconv).to receive(:convert).and_raise(IOError) # raise IOError as if Libreoffice exe were not found
      expect { subject.save! }.to change { Document.count }.by(1) # error handled and document is still saved
    end
  end

  context '#add_converted_preview_document' do
    subject { build(:document) }

    before { allow(Libreconv).to receive(:convert) }

    it 'is triggered by document#save' do
      expect(subject).to receive(:add_converted_preview_document)
      subject.save!
    end

    it 'assigns converted_preview_document a file' do
      expect(subject.converted_preview_document.present?).to be false
      subject.save!
      expect(subject.converted_preview_document.present?).to be true
    end
  end

  context 'save_and_verify' do
    let(:document) { build :document }

    after(:each) { FileUtils.rm TEMPFILE_NAME if File.exist? TEMPFILE_NAME }

    context 'save without verification' do
      it 'has not recorded verified filesize, path and is not verified' do
        document.save!
        expect(document.verified_file_size).to be_nil
        expect(document.file_path).to be_blank
        expect(document.verified).to be false
      end
    end

    context 'success' do
      it 'records filesize, path and verified in the record' do
        allow(LogStuff).to receive(:info).exactly(2)

        expect(document.save_and_verify).to be true
        expect(document.verified_file_size).to eq 49993
        expect(document.file_path).to_not be_blank
        expect(document.verified).to be true
        expect(LogStuff).to have_received(:info).exactly(1).with(:paperclip, action: 'save', document_id: document.id, claim_id: document.claim_id, filename: document.document_file_name, form_id: document.form_id)
        expect(LogStuff).to have_received(:info).exactly(1).with(:paperclip, action: 'verify', document_id: document.id, claim_id: document.claim_id, filename: document.document_file_name, form_id: document.form_id)
      end
    end

    context 'failure to verify' do
      it 'marks the document as unverified' do
        file_path = make_empty_temp_file
        allow(document).to receive(:reload_saved_file).and_return(file_path)

        allow(LogStuff).to receive(:info).exactly(1)
        allow(LogStuff).to receive(:error).exactly(1)

        expect(document.save_and_verify).to be false
        expect(document.verified_file_size).to eq 0
        expect(document.file_path).not_to be_blank
        expect(document.verified).to be false

        expect(LogStuff).to have_received(:info).exactly(1).with(:paperclip, action: 'save', document_id: document.id, claim_id: document.claim_id, filename: document.document_file_name, form_id: document.form_id)
        expect(LogStuff).to have_received(:error).exactly(1).with(:paperclip, action: 'verify_fail', document_id: document.id, claim_id: document.claim_id, filename: document.document_file_name, form_id: document.form_id)
      end
    end

    context 'failure to save' do
      it 'logs and returns false' do
        allow(LogStuff).to receive(:error).exactly(1)
        allow(document).to receive(:save).and_return(false)

        expect(document.save_and_verify).to be false
        expect(document.verified_file_size).to eq nil
        expect(document.file_path).to be_blank
        expect(document.verified).to be false
        expect(LogStuff).to have_received(:error).exactly(1).with(:paperclip, action: 'save_fail', document_id: document.id, claim_id: document.claim_id, filename: document.document_file_name, form_id: document.form_id)
      end
    end

    context 'exception trying to verify' do
      it 'populates the error hash' do
        allow(LogStuff).to receive(:error).exactly(1)
        allow(document).to receive(:save).and_return(true)
        expect(document).to receive(:reload_saved_file).and_raise(RuntimeError, 'my error message')

        expect(document.save_and_verify).to be false
        expect(document.verified_file_size).to eq nil
        expect(document.file_path).to be_blank
        expect(document.verified).to be false
        expect(LogStuff).to have_received(:error).exactly(1).with(:paperclip, action: 'verify_fail', document_id: document.id, claim_id: document.claim_id, filename: document.document_file_name, form_id: document.form_id)
        expect(document.errors[:document]).to match_array(['my error message'])
      end
    end

    def make_empty_temp_file
      require 'fileutils'
      FileUtils.mkdir_p File.dirname(TEMPFILE_NAME)
      file_paths = FileUtils.touch TEMPFILE_NAME
      file_paths.first
    end
  end

  context '#copy_from' do
    let(:document) { build(:document) }
    let(:new_document) { build(:document, :empty) }

    before(:each) do
      document.save_and_verify
      new_document.save_and_verify
    end

    it 'copies and verifies the document data' do
      expect(new_document.verified).to be_falsey
      expect(new_document.verified_file_size).to eq(0)

      # Wait for document creation to finish if necessary
      5.times do
        break if File.exist?(document.file_path)
        sleep 0.1
      end

      new_document.copy_from(document, verify: true)
      expect(new_document.verified).to be_truthy
      expect(new_document.verified_file_size).not_to eq(0)
      expect(new_document.verified_file_size).to eq(document.verified_file_size)
    end
  end
end
