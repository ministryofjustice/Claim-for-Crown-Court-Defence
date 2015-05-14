require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:document_type) }

  it { should belong_to(:claim) }
  it { should validate_presence_of(:document_type) }

  it { should have_attached_file(:document) }
  it { should validate_attachment_presence(:document) }

  it do
    should validate_attachment_content_type(:document).
      allowing('application/pdf',
               'application/msword',
               'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
               'application/vnd.oasis.opendocument.text',
               'text/rtf',
               'application/rtf').
               rejecting('text/plain',
                         'text/html')
  end

  context 'storage' do
    context 'on S3' do
      subject { build(:document) }
      before { allow(subject).to receive(:duplicate_attachment_as_pdf).and_return(nil)}

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

end
