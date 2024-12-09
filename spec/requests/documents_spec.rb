require 'rails_helper'

RSpec.shared_examples 'download evidence document' do
  let(:document) { create(:document, :with_preview, external_user: document_owner) }
  let(:document_owner) { external_user }
  let(:test_url) { 'https://document.storage/document.doc#123abc' }

  before do
    allow(Document).to receive(:find).with(document.to_param).and_return(document)
    allow(document.document.blob).to receive(:url) { |args|
      "#{test_url}?response-content-disposition=#{args[:disposition] || 'inline'}"
    }
    allow(document.converted_preview_document.blob).to receive(:url) { |args|
      "#{test_url}?response-content-disposition=#{args[:disposition] || 'inline'}"
    }
  end

  context 'when the document is owned by the logged in user' do
    it { is_expected.to redirect_to "#{test_url}?response-content-disposition=#{expected_disposition}" }
  end

  context 'when the document is owned by another user' do
    let(:document_owner) { create(:external_user) }

    it { is_expected.to redirect_to external_users_root_url }
  end

  context 'when the user is not signed in' do
    before { sign_out user }

    it { is_expected.to redirect_to new_user_session_url }
  end
end

RSpec.shared_examples 'failed document upload' do
  it 'does not create a document' do
    expect { create_document }.not_to change(Document, :count)
  end

  it 'returns status unprocessable entity' do
    create_document
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns errors in response' do
    create_document
    expect(response.parsed_body).to have_key('error')
  end
end

RSpec.describe 'Document management' do
  let(:external_user) { create(:external_user) }
  let(:user) { external_user.user }

  before { sign_in user }

  describe 'GET /documents' do
    subject(:index_documents) { get documents_path, params: }

    let(:params) { {} }

    context 'when form_id not present' do
      before { index_documents }

      it 'returns an empty JSON set' do
        expect(response.body).to eq([].to_json)
      end
    end

    context 'when form_id present' do
      let(:params) { { form_id: } }
      let(:form_id) { SecureRandom.uuid }
      let!(:matching_documents) { create_list(:document, 2, form_id:) }

      before do
        create_list(:document, 1, form_id: SecureRandom.uuid)
        index_documents
      end

      it 'returns documents matching the form_id' do
        ids = response.parsed_body.pluck('id')
        expect(ids).to match_array(matching_documents.map(&:id))
      end
    end
  end

  describe 'GET /documents/:id' do
    subject(:show_document) { get document_path(document) }

    it_behaves_like 'download evidence document' do
      let(:expected_disposition) { 'inline' }
    end

    context 'when the preview does not exist' do
      let(:document) { create(:document, external_user: document_owner) }
      let(:document_owner) { external_user }

      before { show_document }

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe 'GET /documents/:id/download' do
    it_behaves_like 'download evidence document' do
      subject(:download_document) { get download_document_path(document) }

      let(:expected_disposition) { 'attachment' }
    end
  end

  describe 'POST /documents' do
    subject(:create_document) { post documents_path, params: }

    let(:params) do
      {
        document: {
          document: Rack::Test::UploadedFile.new(Rails.root + 'features/examples/longer_lorem.pdf', 'application/pdf')
        }
      }
    end

    context 'when the document is valid' do
      it 'creates a document' do
        expect { create_document }.to change(Document, :count).by(1)
      end

      it 'returns status created' do
        create_document
        expect(response).to have_http_status(:created)
      end

      it 'returns the id of the created document' do
        create_document
        expect(response.parsed_body['document']['id']).to eq Document.last.id
      end

      it 'returns the file name of the document' do
        create_document
        expect(response.parsed_body['document']['filename']).to eq 'longer_lorem.pdf'
      end
    end

    it_behaves_like 'failed document upload' do
      let(:params) do
        {
          document: {
            document: Rack::Test::UploadedFile.new(Rails.root + 'features/examples/longer_lorem.html', 'text/html')
          }
        }
      end
    end

    it_behaves_like 'failed document upload' do
      let(:params) { { document: { document: nil } } }
    end
  end

  describe 'DELETE /documents/:id' do
    subject(:delete_document) { delete document_path(document, format: :json) }

    let!(:document) { create(:document, :with_preview, external_user_id: external_user.id) }

    it { expect { delete_document }.to change(Document, :count).by(-1) }
    it { expect { delete_document }.to change(ActiveStorage::Attachment, :count).by(-2) }
    it { expect { delete_document }.to change(ActiveStorage::Blob, :count).by(-2) }

    context 'when the ActiveStorage::Blobs are attached to another document' do
      before do
        other = build(:document, :empty)
        other.document.attach(document.document.blob)
        other.converted_preview_document.attach(document.converted_preview_document.blob)
        other.save
      end

      it { expect { delete_document }.to change(Document, :count).by(-1) }
      it { expect { delete_document }.to change(ActiveStorage::Attachment, :count).by(-2) }
      it { expect { delete_document }.not_to change(ActiveStorage::Blob, :count) }
    end
  end

  describe 'POST /documents/upload' do
    subject(:create_document) { post upload_documents_path, params: }

    let(:params) do
      {
        documents: Rack::Test::UploadedFile.new(Rails.root + 'features/examples/longer_lorem.pdf', 'application/pdf')
      }
    end

    context 'when the document is valid' do
      it 'creates a document' do
        expect { create_document }.to change(Document, :count).by(1)
      end

      it 'returns status created' do
        create_document
        expect(response).to have_http_status(:created)
      end

      it 'returns the id of the created document' do
        create_document
        # The MultiFileUpload uses the filename as the only paramater to identify the document for the delte button
        # For this reason the 'filename' in the response is the document id
        expect(response.parsed_body['file']['filename']).to eq Document.last.id
      end

      it 'returns a success message' do
        create_document
        expect(response.parsed_body['success']).to have_key('messageHtml')
      end
    end

    context 'when the document is invalid' do
      let(:params) do
        {
          documents: Rack::Test::UploadedFile.new(Rails.root + 'features/examples/longer_lorem.html', 'text/html')
        }
      end

      it 'does not create a document' do
        expect { create_document }.not_to change(Document, :count)
      end
    
      it 'returns status unprocessable entity' do
        create_document
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
      it 'returns errors in response' do
        create_document
        expect(response.parsed_body['error']).to have_key('message')
      end
    end

    context 'when the document is missing' do
      let(:params) { { documents: nil } }

      it 'does not create a document' do
        expect { create_document }.not_to change(Document, :count)
      end
    
      it 'returns status unprocessable entity' do
        create_document
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
      it 'returns errors in response' do
        create_document
        expect(response.parsed_body['error']).to have_key('message')
      end
    end
  end
end
