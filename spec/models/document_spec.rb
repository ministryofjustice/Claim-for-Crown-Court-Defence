require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:document_type) }

  it { should belong_to(:advocate) }
  it { should delegate_method(:chamber_id).to(:advocate) }
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

  context 'attachment conversion' do

    subject { build(:document, :docx, document_content_type: 'application/msword') }

    it 'is triggered by document#save when the attachment is not a pdf' do
      expect(subject).to receive(:duplicate_attachment_as_pdf).and_return(nil)
      subject.save!
    end

    it 'does not prevent document save if Libreconv is not found' do
      expect(Libreconv).to receive(:convert).and_raise(IOError) # stub method call and raise IOError
      expect{ subject.save! }.to change{ Document.count }.by(1) # error caught by begin|rescue|end in document model
    end

  end

  context '#new_filename' do

    subject { build(:document, :docx, document_content_type: 'application/msword') }

    it 'specifies file name of converted attachment, with .pdf extension' do
      expect(subject.new_filename).to eq 'shorter_lorem.pdf'
    end
  end

  context '#path_to_pdf_duplicate' do

    subject { create(:document) }

    it 'returns the path to .pdf copy of attachment' do
      expect(File.exist?(subject.path_to_pdf_duplicate)).to eq true
    end
  end

  context 'attachment is present as a pdf / pdf duplicate' do

    subject { create(:document) }

    it '#has_pdf_duplicate? returns true' do
      expect(subject.has_pdf_duplicate?).to eq true
    end
  end

  context 'attachment is not present as a pdf / pdf duplicate' do

    before { allow(Libreconv).to receive(:convert).and_raise(IOError) } #stub call to convert so the pdf is not generated
    subject { create(:document, :docx, document_content_type: 'application/msword') } # create a doc with docx attachment

    it '#has_pdf_duplicate? returns false' do
      expect(subject.has_pdf_duplicate?).to eq false # pdf is not available
    end
  end

end