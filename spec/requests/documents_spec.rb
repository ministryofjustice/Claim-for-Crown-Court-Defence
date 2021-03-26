require 'rails_helper'

RSpec.shared_examples 'download evidence document' do
  let(:document) { create :document, external_user: document_owner }
  let(:document_owner) { external_user }
  let(:test_url) { 'https://example.com/document.doc#123abc' }

  before do
    allow(Document).to receive(:find).with(document.to_param).and_return(document)
    allow(document.document.blob).to receive(:service_url).and_return(test_url)
    allow(document.converted_preview_document.blob).to receive(:service_url) { |args|
      "#{test_url}?response-content-disposition=#{args[:disposition] || 'inline'}"
    }
  end

  context 'when the document is owned by the logged in user' do
    it { is_expected.to redirect_to "#{test_url}?response-content-disposition=#{expected_disposition}" }
  end

  context 'when the document is owned by another user' do
    let(:document_owner) { create :external_user }

    it { is_expected.to redirect_to external_users_root_url }
  end

  context 'when the user is not signed in' do
    before { sign_out user }

    it { is_expected.to redirect_to new_user_session_url }
  end
end

RSpec.describe '/documents', type: :request do
  let(:external_user) { create :external_user }
  let(:user) { external_user.user }

  before { sign_in user }

  describe 'GET /documents/:id' do
    it_behaves_like 'download evidence document' do
      subject(:show_document) { get document_path(document) }

      let(:expected_disposition) { 'inline' }
    end
  end

  describe 'GET /documents/:id/download' do
    it_behaves_like 'download evidence document' do
      subject(:download_document) { get download_document_path(document) }

      let(:expected_disposition) { 'attachment' }
    end
  end
end
