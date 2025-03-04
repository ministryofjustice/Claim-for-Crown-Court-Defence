require 'rails_helper'

RSpec.describe 'Messages' do
  describe 'POST /messages' do
    subject(:submit) { post messages_path, params: { message: message_params } }

    let(:creator) { create(:external_user) }
    let(:sender) { creator }
    let(:message_params) { { claim_id: claim.id, body: 'lorem ipsum' } }
    let(:claim) { create(:advocate_claim, creator: creator) }

    before { sign_in sender.user }

    context 'when the claim belongs to the currently logged in user' do
      it { expect { submit }.to change(Message, :count).by(1) }
    end

    context 'when the logged in user is a case worker' do
      let(:sender) { create(:case_worker) }

      it { expect { submit }.to change(Message, :count).by(1) }
    end

    context 'when the logged in user is an external user of the same provider as the creator' do
      let(:sender) { create(:external_user, provider: creator.provider) }

      it { expect { submit }.to change(Message, :count).by(1) }
    end

    context 'when the logged in user is an external user from a different provider' do
      let(:sender) { create(:external_user) }

      before { pending 'Messages not yet restricted to current user' }

      it { expect { submit }.not_to change(Message, :count) }
    end

    context 'when the message is blank' do
      let(:message_params) { { claim_id: claim.id, body: '' } }

      it { expect { submit }.not_to change(Message, :count) }
    end

    context 'when the claim does not exist' do
      let(:message_params) { { claim_id: 0, body: 'lorem ipsum' } }

      it { expect { submit }.not_to change(Message, :count) }
    end

    context 'when the claim id is missing' do
      let(:message_params) { { body: 'lorem ipsum' } }

      it { expect { submit }.not_to change(Message, :count) }
    end

    context 'with a refused claim' do
      before do
        claim.submit!
        claim.allocate!
        claim.refuse!
      end

      context 'when redetermining' do
        let(:message_params) { { claim_id: claim.id, body: 'lorem ipsum', claim_action: 'Apply for redetermination' } }

        it do
          submit
          expect(response).to redirect_to(external_users_claim_path(claim, messages: true) + '#claim-accordion')
        end
      end

      context 'when requesting written reasons' do
        let(:message_params) { { claim_id: claim.id, body: 'lorem ipsum', claim_action: 'Request written reasons' } }

        it do
          submit
          expect(response).to redirect_to(external_users_claim_path(claim, messages: true) + '#claim-accordion')
        end
      end
    end

    context 'when there are documents attached' do
      let(:message_params) { { claim_id: claim.id, body: 'lorem ipsum', document_ids: documents.map(&:id) } }
      let(:documents) { create_list(:document, 2, creator_id: creator.id) }

      it { expect { submit }.to change(Message, :count).by(1) }

      it do
        submit
        expect(Message.last.attachments.count).to eq(2)
      end
    end
  end
end
