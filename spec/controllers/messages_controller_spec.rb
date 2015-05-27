require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:sender) { create(:advocate) }

  before do
    sign_in sender.user
  end

  describe "GET #create" do
    let(:claim) { create(:claim) }
    let(:message_params) do
      {
        claim_id: claim.id,
        sender_id: sender.user.id,
        subject: 'hello',
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
end
