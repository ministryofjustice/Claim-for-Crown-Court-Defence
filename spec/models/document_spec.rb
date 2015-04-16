require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:claim) }
  it { should validate_presence_of(:claim) }
  it { should validate_presence_of(:description) }

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
    context 'S3' do
      subject { build(:document) }

      it 'saves the original to AWS' do
        stub_request(:put, /https\:\/\/moj-cbo-documents-test\.s3\.amazonaws\.com\/.+\/shorter_lorem.docx/).
          with(headers: {
          "Content-Type" => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          "Content-Length" => '5055'})

          expect{ subject.save! }.not_to raise_error
      end

    end
  end

end
