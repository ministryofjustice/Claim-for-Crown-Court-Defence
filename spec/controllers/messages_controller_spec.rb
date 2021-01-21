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
  context 'standard sign in' do
    let(:sender) { create(:external_user) }

    before do
      sign_in sender.user
    end

    describe 'POST #create' do
      let(:claim) { create(:advocate_claim) }
      let(:message_params) do
        {
          claim_id: claim.id,
          sender_id: sender.user.id,
          body: 'lorem ipsum'
        }
      end

      it 'renders the create js template' do
        post :create, params: { message: message_params }, xhr: true
        expect(response).to render_template(:create)
      end

      context 'when valid' do
        it 'creates a message' do
          expect {
            post :create, params: { message: message_params }
          }.to change(Message, :count).by(1)
        end

        context 'when redetermining/awaiting written reasons' do
          it 'redirects to externl users claim show path with messages param and accordion anchor' do
            claim.submit!; claim.allocate!; claim.refuse!

            Settings.claim_actions.each do |action|
              post :create, params: { message: message_params.merge(claim_action: action) }
              expect(response).to redirect_to(external_users_claim_path(claim, messages: true) + '#claim-accordion')
            end
          end
        end
      end

      context 'when invalid' do
        before do
          message_params.delete(:claim_id)
        end

        # TODO: We must handle the fact that if the message cannot be created, there will not be ID to redirect to (redirect_to_url)
        xit 'does not create a message' do
          expect {
            post :create, params: { message: message_params }
          }.to_not change(Message, :count)
        end
      end
    end

    describe 'GET #download_attachment' do
      subject(:download_attachment) { get :download_attachment, params: { id: message.id } }

      context 'when message has attachment' do
        let(:message) { create(:message, :with_attachment) }
        let(:service_url) { 'https://example.com/document.pdf' }

        before do
          allow_any_instance_of(ActiveStorage::Blob).to receive(:service_url).and_return(service_url)
        end

        it 'redirects to the attachment' do
          expect(download_attachment).to redirect_to service_url
        end
      end

      context 'when message does not have attachment' do
        let(:message) { create(:message) }

        it 'redirects to 500 page' do
          expect {
            download_attachment
          }.to raise_exception('No attachment present on this message')
        end
      end
    end
  end

  context 'email notifications' do
    let(:claim) { create :claim }
    let(:message_params) { message_params = { claim_id: claim.id, sender_id: sender.user.id, body: 'lorem ipsum' } }

    context 'external_user_sending_messages' do
      let(:sender) { claim.creator }

      context 'claim creator is set up to receive mails' do
        it 'does not attempt to send an email' do
          sender.email_notification_of_message = 'true'
          sign_in sender.user
          expect(NotifyMailer).not_to receive(:message_added_email)
          post :create, params: { message: message_params }
        end
      end

      context 'claim creator is set up NOT to receive mails' do
        it 'does not attempt to send an email' do
          sender.email_notification_of_message = 'false'
          sign_in sender.user
          expect(NotifyMailer).not_to receive(:message_added_email)
          post :create, params: { message: message_params }
        end
      end
    end

    context 'case_worker_sending_messages' do
      let(:sender) { create :case_worker }

      context 'claim creator is set up to receive mails' do
        it 'sends an email' do
          claim.creator.email_notification_of_message = 'true'
          sign_in sender.user
          mock_mail = double 'Mail message'
          expect(NotifyMailer).to receive(:message_added_email).and_return(mock_mail)
          expect(mock_mail).to receive(:deliver_later)
          post :create, params: { message: message_params }
        end

        context 'but has been deleted' do
          before do
            claim.creator.email_notification_of_message = 'true'
            claim.creator.soft_delete
            sign_in sender.user
          end

          it 'does not send an email' do
            expect(NotifyMailer).not_to receive(:message_added_email)
            post :create, params: { message: message_params }
          end
        end
      end
      context 'external_user_is_not_setup_to_recieve_emails' do
        it 'does not send an email' do
          claim.creator.email_notification_of_message = 'false'
          sign_in sender.user
          expect(NotifyMailer).not_to receive(:message_added_email)
          post :create, params: { message: message_params }
        end
      end
    end
  end
end
