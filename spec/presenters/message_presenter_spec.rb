require 'rails_helper'

RSpec.describe MessagePresenter, type: :helper do
  subject(:presenter) { described_class.new message, helper }

  let(:attachments) { nil }
  let(:message) { build(:message, attachments: [attachments]) }

  describe '#body' do
    context 'without an attachment' do
      it 'does not include a download link for the attachment' do
        expect(presenter.body).not_to match(%r{Attachment:\s*<a.*>.*</a>})
      end
    end

    context 'with an attachment' do
      let(:file) { File.expand_path('features/examples/shorter_lorem.docx', Rails.root) }
      let(:file_size) { number_to_human_size(File.size(file)) }
      let(:attachments) { Rack::Test::UploadedFile.new(file) }

      before do
        allow(message.attachments.first).to receive(:url).and_return('http://example.com')
      end

      it 'includes a download link to the attachment' do
        expect(presenter.body)
          .to match(%r{<div>.*Attachments: <br><a.*>shorter_lorem.docx \(14.4 KB\)</a>.*</div>})
      end
    end
  end
end
