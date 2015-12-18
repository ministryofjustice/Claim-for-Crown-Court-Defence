require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:sender) { create(:advocate) }

  before do
    sign_in sender.user
  end

  describe "GET #index" do
    context 'when claim_id present' do
      let!(:claim) { create(:submitted_claim) }
      let!(:another_claim) { create(:submitted_claim) }

      let!(:message_1) { create(:message, claim: claim) }
      let!(:message_2) { create(:message, claim: claim) }
      let!(:message_3) { create(:message, claim: another_claim) }

      it 'returns all messages for specified claim id' do
        xhr :get, :index, claim_id: claim.id
        expect(assigns(:messages)).to match_array([message_1, message_2])
      end
    end

    context 'when no claim id present' do
      it 'raises error' do
        expect{get :index}.to raise_error('Must specifiy claim id')
      end
    end
  end

  describe "POST #create" do
    let(:claim) { create(:claim) }
    let(:message_params) do
      {
        claim_id: claim.id,
        sender_id: sender.user.id,
        body: 'lorem ipsum',
      }
    end

    before do
      request.env['HTTP_REFERER'] = advocates_claim_path(claim)
    end

    context 'when valid' do
      it 'creates a message' do
        expect {
          post :create, message: message_params
        }.to change(Message, :count).by(1)
      end
    end

    context 'when invalid' do
      it 'does not create a message' do
        message_params.delete(:claim_id)

        expect {
          post :create, message: message_params
        }.to_not change(Message, :count)
      end
    end
  end

  describe 'GET #download_attachment' do
    context 'when message has attachment' do
      subject { create(:message, :with_attachment) }

      it 'returns the attachment file' do
        get :download_attachment, id: subject.id
        expect(response.headers['Content-Disposition']).to include("filename=\"#{subject.attachment.original_filename}\"")
      end
    end

    context 'when message does not have attachment' do
      subject { create(:message) }

      it 'raises exception' do
        expect{ get :download_attachment, id: subject.id }.to raise_exception('No attachment present on this message')
      end
    end
  end
end
