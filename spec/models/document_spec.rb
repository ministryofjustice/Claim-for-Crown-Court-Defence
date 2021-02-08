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
  it { is_expected.to belong_to(:external_user) }
  it { is_expected.to belong_to(:creator).class_name('ExternalUser') }
  it { is_expected.to belong_to(:claim) }
  it { is_expected.to delegate_method(:provider_id).to(:external_user) }

  it { is_expected.to have_one_attached :document }
  it { is_expected.to validate_presence_of :document }

  it { is_expected.to have_one_attached :converted_preview_document }
  it { is_expected.to validate_content_type_of(:converted_preview_document).allowing('application/pdf') }

  it_behaves_like 'an s3 bucket'

  it do
    is_expected.to validate_content_type_of(:document)
      .allowing(
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
      ).rejecting('text/plain', 'text/html')
  end

  it { should validate_size_of(:document).less_than_or_equal_to(20.megabytes) }

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

  context '#save!' do
    subject { build(:document, :docx, document_content_type: 'application/msword') }

    it 'depends on the Libreconv gem' do
      expect(Libreconv).to receive(:convert)
      subject.save!
    end

    it 'handles IOError when Libreconv is not in PATH' do
      allow(Libreconv).to receive(:convert).and_raise(IOError) # raise IOError as if Libreoffice exe were not found
      expect { subject.save! }.to change(Document, :count).by(1) # error handled and document is still saved
    end
  end

  describe '#save_and_verify' do
    let(:document) { build :document }

    it 'marks the document as verified' do
      # With Active Storage (for the moment) verified will always be true
      # TODO: Either remove verified or implement a verification check
      expect { document.save_and_verify }.to change(document, :verified).from(false).to true
    end
  end

  context '#copy_from' do
    subject(:new_document) { build(:document, :empty) }

    let(:file) do
      Rack::Test::UploadedFile.new(
        File.expand_path('features/examples/longer_lorem.pdf', Rails.root),
        'application/pdf'
      )
    end
    let(:verified) { true }
    let(:old_document) { create :document, document: file, verified: verified }

    before { new_document.copy_from old_document }

    it 'copies the document from the old document' do
      expect(new_document.document.checksum).to eq old_document.document.checksum
    end

    it 'copies the document filename from the old document' do
      expect(new_document.document.filename).to eq old_document.document.filename
    end

    it 'copies the document preview from the old document' do
      expect(new_document.converted_preview_document.checksum)
        .to eq old_document.converted_preview_document.checksum
    end

    it 'copies the document preview filename from the old document' do
      expect(new_document.converted_preview_document.filename)
        .to eq old_document.converted_preview_document.filename
    end

    context 'when the document is verified' do
      it 'sets the new document as verified' do
        expect(new_document.verified).to be_truthy
      end
    end

    context 'when the document is not verified' do
      let(:verified) { false }

      it 'sets the new document as not verified' do
        expect(new_document.verified).to be_falsey
      end
    end
  end

  describe '#document_file_name' do
    # For backward compatibility with Paperclip.
    subject(:document_file_name) { document.document_file_name }
    let(:document) { build :document, :empty }
    let(:filename) { 'test_file.doc' }

    before { document.document.attach(io: StringIO.new('stuff'), filename: filename) }

    it 'is the name of the file' do
      expect(document_file_name).to eq filename
    end
  end

  describe '#document_file_size' do
    # For backward compatibility with Paperclip.
    subject(:document_file_size) { document.document_file_size }
    let(:document) { build :document, :empty }
    let(:filename) { 'test_file.doc' }

    before { document.document.attach(io: StringIO.new('x' * 1024), filename: filename) }

    it 'is the size of the file in bytes' do
      expect(document_file_size).to eq 1024
    end
  end
end
