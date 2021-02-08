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

RSpec.describe DocumentsController, type: :controller do
  let(:external_user) { create(:external_user) }
  let(:user) { external_user.user }

  before { sign_in user }

  describe 'GET #index' do
    let(:params) { {} }

    context 'when form_id not present' do
      it 'returns an empty JSON set' do
        get :index, params: params
        expect(response.body).to eq([].to_json)
      end
    end

    context 'when form_id present' do
      let!(:form_id) { SecureRandom.uuid }
      let!(:matching_documents) { create_list(:document, 2, form_id: form_id) }
      let!(:not_matching_documents) { create_list(:document, 1, form_id: SecureRandom.uuid) }

      let(:params) { { form_id: form_id } }

      before { get :index, params: params }

      it 'returns documents matching the form_id' do
        ids = JSON.parse(response.body).map { |h| h['id'] }
        expect(ids).to match_array(matching_documents.map(&:id))
      end
    end
  end

  shared_examples 'view document' do
    let(:service_url) { 'https://example.com/document.pdf' }

    context 'with a document owned by the logged in user' do
      let(:document) { create :document, external_user: external_user }

      before do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:service_url).and_return(service_url)
      end

      it 'redirects to the attachment' do
        expect(view_document).to redirect_to service_url
      end
    end

    context 'with a document owned by a different user' do
      let(:document) { create :document, external_user: create(:external_user) }

      it 'redirects to the claims page' do
        expect(view_document).to redirect_to external_users_root_url
      end
    end

    context 'when signed out' do
      let(:document) { create :document, external_user: create(:external_user) }

      before { sign_out user }

      it 'redirects to the login page' do
        expect(view_document).to redirect_to new_user_session_url
      end
    end
  end

  describe 'GET #show' do
    # TODO: 1) The shared examples test that the user is redirected to a
    #       download link but it is not check that it is the link for
    #       converted_preview_document.
    #       2) There isn't a test for whether the disposition is 'attachment'
    #       or 'inline'.
    subject(:view_document) { get :show, params: { id: document.id } }

    include_examples 'view document'
  end

  describe 'GET #download' do
    subject(:view_document) { get :download, params: { id: document.id } }

    include_examples 'view document'
  end

  describe 'POST #create' do
    subject(:create_document) { post :create, params: { document: params } }

    let(:params) { { document: document } }

    context 'when valid' do
      let(:document) { Rack::Test::UploadedFile.new(Rails.root + 'features/examples/longer_lorem.pdf', 'application/pdf') }

      it 'creates a document' do
        expect { create_document }.to change(Document, :count).by(1)
      end

      it 'returns status created' do
        create_document
        expect(response.status).to eq(201)
      end

      # TODO: Check that nothing other than id and filename are required
      # it 'returns the created document as JSON' do
      #   create_document
      #   expect(JSON.parse(response.body)['document']).to eq(JSON.parse(Document.first.to_json))
      # end

      it 'includes the document id in the response' do
        create_document
        expect(JSON.parse(response.body)['document']['id']).to eq Document.last.id
      end

      it 'includes the document filename in the response' do
        create_document
        # TODO: Change to something not so Paperclip-esque
        # This is used in app/webpack/javascript/external_users/claims/Dropzone.js
        expect(JSON.parse(response.body)['document']['document_file_name']).to eq 'longer_lorem.pdf'
      end
    end

    context 'when invalid' do
      let(:document) { Rack::Test::UploadedFile.new(Tempfile.new, 'video/mpeg') }

      it 'does not create a document' do
        expect { create_document }.to_not change(Document, :count)
      end

      it 'returns status unprocessable entity' do
        create_document
        expect(response.status).to eq(422)
      end

      it 'returns errors in response' do
        create_document
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:document) { create(:document, external_user_id: external_user.id) }

    it 'destroys the document' do
      expect {
        delete :destroy, params: { id: document.id }, format: :json
      }.to change(Document, :count).by(-1)
    end

    it 'responds with errors if unable to destroy the document' do
      expect_any_instance_of(Document).to receive(:destroy).and_return(false)
      expect {
        delete :destroy, params: { id: document.id }, format: :json
      }.not_to change(Document, :count)
    end
  end

  def binread(path)
    5.times do
      break if File.exist?(path)
      sleep 0.5
    end
    IO.binread(path)
  end
end
