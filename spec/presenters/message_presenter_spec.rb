require 'rails_helper'

RSpec.describe MessagePresenter, type: :helper do
  subject(:presenter) { described_class.new message, helper }

  let(:attachment) { nil }
  let(:message) { build(:message, attachment:) }

  describe '#body' do
    context 'without an attachment' do
      it 'does not include a download link for the attachment' do
        expect(presenter.body).not_to match(%r{Attachment:\s*<a.*>.*</a>})
      end
    end

    context 'with an attachment' do
      let(:file) { File.expand_path('features/examples/shorter_lorem.docx', Rails.root) }
      let(:file_size) { number_to_human_size(File.size(file)) }
      let(:attachment) { [Rack::Test::UploadedFile.new(file)] }

      before do
        allow(message.attachment.first).to receive(:url).and_return('http://example.com')
      end

      it 'includes a download link to the attachment' do
        expect(presenter.body)
          .to match(%r{Attachment:\s*<a.*>shorter_lorem.docx \(#{file_size}\)</a>})
      end
    end
  end
end
