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

RSpec.describe Document, type: :model do
  it { is_expected.to belong_to(:external_user) }
  it { is_expected.to belong_to(:creator).class_name('ExternalUser') }
  it { is_expected.to belong_to(:claim) }
  it { is_expected.to delegate_method(:provider_id).to(:external_user) }

  it { is_expected.to have_one_attached(:document) }
  it { is_expected.to validate_presence_of(:document) }
  it { is_expected.to validate_size_of(:document).less_than_or_equal_to(20.megabytes) }

  it do
    is_expected.to validate_content_type_of(:document).allowing(
      'application/pdf', 'application/msword', 'application/vnd.oasis.opendocument.text', 'application/rtf',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/rtf',
      'image/jpeg', 'image/png', 'image/tiff', 'image/bmp', 'image/x-bitmap'
    ).rejecting('text/plain', 'text/html')
  end

  it { is_expected.to have_one_attached(:converted_preview_document) }
  it { is_expected.to validate_content_type_of(:converted_preview_document).allowing('application/pdf') }

  describe '#save' do
    subject(:document_save) { document.save }

    let(:document) { build :document, trait, claim: claim, form_id: claim.form_id }
    let(:claim) { create :claim }
    let(:trait) { :pdf }

    context 'with a pdf document' do
      before { document_save }

      it 'creates the preview as a copy of the original' do
        expect(document.converted_preview_document.checksum).to eq document.document.checksum
      end
    end

    context 'with a docx document' do
      let(:trait) { :docx }

      before { document_save }

      it 'creates a preview that is different from the original' do
        expect(document.converted_preview_document.checksum).not_to eq document.document.checksum
      end

      it 'creates a preview of type application/pdf' do
        expect(document.converted_preview_document.content_type).to eq 'application/pdf'
      end

      it 'creates a preview with name based on the orginal' do
        expect(document.converted_preview_document.filename).to eq "#{document.document.filename}.pdf"
      end
    end

    context 'when Libreconv fails' do
      let(:trait) { :docx }

      before { allow(Libreconv).to receive(:convert).and_raise(IOError) }

      it { expect { document_save }.not_to raise_error }
    end

    context 'when the maximum document limit is reached' do
      before do
        allow(Settings).to receive(:max_document_upload_count).and_return 2
        create_list :document, 2, claim: claim, form_id: claim.form_id
      end

      it { expect(document).not_to be_valid }

      it 'reports a sensible error' do
        document_save
        expect(document.errors[:document]).to include('Total documents exceed maximum of 2. This document has not been uploaded.')
      end
    end

    context 'when allowing for Paperclip rollback' do
      before { document_save }

      it 'sets document_file_name' do
        expect(document.document_file_name).to eq document.document.filename.to_s
      end

      it 'sets document_file_size' do
        expect(document.document_file_size).to eq document.document.byte_size
      end

      it 'sets document_content_type' do
        expect(document.document_content_type).to eq document.document.content_type
      end

      it 'sets document_updated_at' do
        expect(document.document_updated_at).not_to be_nil
      end

      it 'sets as_document_checksum' do
        expect(document.as_document_checksum).to eq document.document.checksum
      end

      it 'sets converted_preview_document_file_name' do
        expect(document.converted_preview_document_file_name).to eq document.converted_preview_document.filename.to_s
      end

      it 'sets converted_preview_document_file_size' do
        expect(document.converted_preview_document_file_size).to eq document.converted_preview_document.byte_size
      end

      it 'sets converted_preview_document_content_type' do
        expect(document.converted_preview_document_content_type).to eq document.converted_preview_document.content_type
      end

      it 'sets converted_preview_document_updated_at' do
        expect(document.converted_preview_document_updated_at).not_to be_nil
      end

      it 'sets as_converted_preview_document_checksum' do
        expect(document.as_converted_preview_document_checksum).to eq document.converted_preview_document.checksum
      end
    end
  end

  describe '#save_and_verify' do
    subject(:save_and_verify) { document.save_and_verify }

    let(:document) { build :document }

    it { expect { save_and_verify }.to change(document, :verified).to true }
  end

  describe '#copy_from' do
    let(:old_document) { create :document, :with_preview, verified: true }
    let(:new_document) { build :document, :empty }

    before { new_document.copy_from(old_document) }

    it 'copies the document from the old document' do
      expect(new_document.document.blob).to eq old_document.document.blob
    end

    it 'copies the converted preview document from the old document' do
      expect(new_document.converted_preview_document.blob).to eq old_document.converted_preview_document.blob
    end

    it 'makes the new document verified' do
      expect(new_document.verified).to be_truthy
    end

    context 'when the old document is not verified' do
      let(:old_document) { create :document, :with_preview, verified: false }

      it 'makes the new document not verified' do
        expect(new_document.verified).to be_falsey
      end
    end
  end
end
