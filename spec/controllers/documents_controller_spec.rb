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

  describe 'GET #show' do
    let(:document) { create(:document, external_user_id: external_user.id) }

    it 'downloads a preview of the document' do
      get :show, params: { id: document.id }
      expect(response.body).to eq binread(document.converted_preview_document.path)
    end
  end

  describe 'GET #download' do
    let(:document) { create(:document, external_user_id: external_user.id) }

    it 'downloads the document' do
      get :show, params: { id: document.id }
      expect(response.body).to eq binread(document.document.path)
    end
  end

  describe 'POST #create' do
    let(:params) do
      {
        document: Rack::Test::UploadedFile.new(Rails.root + 'features/examples/longer_lorem.pdf', 'application/pdf')
      }
    end

    context 'when valid' do
      it 'creates a document' do
        expect {
          post :create, params: { document: params }
        }.to change(Document, :count).by(1)
      end

      it 'returns status created' do
        post :create, params: { document: params }
        expect(response.status).to eq(201)
      end

      it 'returns the created document as JSON' do
        post :create, params: { document: params }
        expect(JSON.parse(response.body)['document']).to eq(JSON.parse(Document.first.to_json))
      end
    end

    context 'when invalid' do
      let(:params) { { document: nil } }

      it 'does not create a document' do
        expect {
          post :create, params: { document: params }
        }.to_not change(Document, :count)
      end

      it 'returns status unprocessable entity' do
        post :create, params: { document: params }
        expect(response.status).to eq(422)
      end

      it 'returns errors in response' do
        post :create, params: { document: params }
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end
  end

  describe 'GET #download' do
    it 'downloads the file' do
      file = Tempfile.new('foo')
      file.write('foo')
      file.close
      document = create :document, external_user: external_user
      paperclip_adapters = double(Paperclip::AdapterRegistry)
      paperclip_document = double(Paperclip::Attachment)
      expect(paperclip_document).to receive(:path).at_least(1).and_return(file.path)
      expect(paperclip_adapters).to receive(:for).at_least(1).with(instance_of(Paperclip::Attachment)).and_return(paperclip_document)
      expect(Paperclip).to receive(:io_adapters).at_least(1).and_return(paperclip_adapters)
      get :download, params: { id: document.id }
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
