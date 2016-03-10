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
#

require 'rails_helper'

RSpec.describe Document, type: :model do

  it { should belong_to(:external_user) }
  it { should belong_to(:creator) }
  it { should belong_to(:claim) }
  it { should delegate_method(:provider_id).to(:external_user) }

  it { should have_attached_file(:document) }
  it { should validate_attachment_presence(:document) }

  it { should have_attached_file(:converted_preview_document) }
  it { should validate_attachment_content_type(:converted_preview_document).allowing('application/pdf') }

  it do
    should validate_attachment_content_type(:document).
      allowing('application/pdf',
               'application/msword',
               'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
               'application/vnd.oasis.opendocument.text',
               'text/rtf',
               'application/rtf',
               'image/jpeg',
               'image/png',
               'image/tiff',
               'image/bmp',
               'image/x-bitmap').
      rejecting('text/plain',
                'text/html')
  end

  it { should validate_attachment_size(:document).in(0.megabytes..20.megabytes) }

  context 'storage' do
    context 'on S3' do
      subject { build(:document) }
      before { allow(subject).to receive(:generate_pdf_tmpfile).and_return(nil)}

      it 'saves the original' do
        stub_request(:put, /https\:\/\/moj-cbo-documents-test\.s3\.amazonaws\.com\/.+\/shorter_lorem\.docx/).
          with(headers: { "Content-Type" => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                          "Content-Length" => '5055'})

          expect{ subject.save! }.not_to raise_error
      end

      it 'uses the canned S3 private ACL' do
        stub_request(:put, /shorter_lorem\.docx/).
          with(headers: { 'X-Amz-Acl' => 'private' })

        expect{ subject.save! }.not_to raise_error
      end

      it 'sets a no-cache header' do
        stub_request(:put, /shorter_lorem\.docx/).
          with(headers: { 'x-amz-meta-Cache-Control' => 'no-cache' })

        expect{ subject.save! }.not_to raise_error
      end

      it 'sets an expiry header' do
        stub_request(:put, /shorter_lorem\.docx/).
          with(headers: { 'Expires' => /.+/ })  # Timecop and paperclip or webmock aren't playing well together.

        expect{ subject.save! }.not_to raise_error
      end
    end
  end

  context '#generate_pdf_tmpfile' do

    context 'when the original attachment is a .docx' do

      subject { build(:document, :docx, document_content_type: 'application/msword') }

      it 'called by a before_save hook' do
        expect(subject).to receive(:generate_pdf_tmpfile)
        subject.save!
      end

      it 'calls document#convert_and_assign_document' do
        expect(subject).to receive(:convert_and_assign_document)
        subject.generate_pdf_tmpfile
      end

    end

    context 'when the original attachment is a .pdf' do

      subject { build(:document) }

      it 'is still called by a before_save hook' do
        expect(subject).to receive(:generate_pdf_tmpfile).and_return(nil)
        subject.save!
      end

      it 'does not call document#convert_and_assign_document' do
        expect(subject).to_not receive(:convert_and_assign_document)
        subject.generate_pdf_tmpfile
      end

      it 'assigns original document to document#pdf_tmpfile' do
        subject.save!
        expect(subject.pdf_tmpfile).to eq subject.document
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
      expect{ subject.save! }.to change{ Document.count }.by(1) # error handled and document is still saved
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

end



