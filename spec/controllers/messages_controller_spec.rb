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

    before do
      request.env['HTTP_REFERER'] = external_users_claim_path(claim)
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
