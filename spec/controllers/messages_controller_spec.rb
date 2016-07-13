# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  body                    :text
#  claim_id                :integer
#  sender_id               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:sender) { create(:external_user) }

  before do
    sign_in sender.user
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

    it 'renders the create js template' do
      xhr :post, :create, message: message_params
      expect(response).to render_template(:create)
    end

    context 'when valid' do
      it 'creates a message' do
        expect {
          post :create, message: message_params
        }.to change(Message, :count).by(1)
      end

      context 'when redetermining/awaiting written reasons' do
        it 'redirects to externl users claim show path with messages param and accordion anchor' do
          claim.submit!; claim.allocate!; claim.refuse!

          Settings.claim_actions.each do |action|
            post :create, message: message_params.merge(claim_action: action)
            expect(response).to redirect_to(external_users_claim_path(claim, messages: true) + '#claim-accordion')
          end
        end
      end
    end

    context 'when invalid' do
      before do
        message_params.delete(:claim_id)
      end

      it 'does not create a message' do
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

      it 'redirects to 500 page' do
        get :download_attachment, id: subject.id
        expect(response).to redirect_to(error_500_path)
      end
    end
  end


end
