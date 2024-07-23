# spec/requests/active_storage_spec.rb

require 'rails_helper'

RSpec.describe 'ActiveStorage', type: :request do
  describe 'GET /rails/active_storage/blobs/:signed_id/:filename' do
    let(:message) { create(:message) }
    let(:attachment_content) { 'dummy content' }
    let(:attachment_filename) { 'attachment.doc' }
    let(:attachment_content_type) { 'application/msword' }

    before do
      message.attachment.attach(io: StringIO.new(attachment_content), filename: attachment_filename, content_type: attachment_content_type)
    end

    context 'when the message has an attachment' do
      subject(:get_attachment) { get rails_blob_path(message.attachment, disposition: 'attachment') }

      it 'redirects to the ActiveStorage blob URL' do
        get_attachment
        expect(response).to have_http_status(:redirect)
        expect(response.headers['Location']).to include('rails/active_storage/blobs/redirect/')
        expect(response.headers['Location']).to include('?disposition=attachment')
      end
    end

    context 'when the message does not have an attachment' do
      let(:message_without_attachment) { create(:message) }

      it 'raises an ActiveRecord::RecordNotFound error' do
        expect {
          get rails_blob_path(message_without_attachment.attachment, disposition: 'attachment', only_path: true)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
