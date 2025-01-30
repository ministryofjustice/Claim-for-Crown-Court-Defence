require 'rails_helper'

RSpec.describe 'send feedback' do
  describe 'GET /feedback/new' do
    let(:params) { {} }

    before { get new_feedback_url, params: }

    it 'assigns a new @feedback' do
      expect(assigns(:feedback)).not_to be_nil
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    context 'with feedback' do
      let(:params) { { type: 'feedback' } }

      it 'renders the feedback template' do
        expect(response).to render_template('feedback/feedback')
      end
    end

    context 'with a bug report' do
      let(:params) { { type: 'bug_report' } }

      it 'renders the bug report template' do
        expect(response).to render_template('feedback/bug_report')
      end
    end
  end

  describe 'POST /feedback (for a bug report)' do
    subject(:post_feedback) { post feedback_index_url, params: { feedback: params } }

    let(:params) { { type: 'bug_report', case_number: 'XXXX', event: 'lorem', outcome: 'ipsum' } }

    before { allow(ZendeskAPI::Ticket).to receive(:create!).and_return(true) }

    context 'when valid' do
      context 'when the user is signed in' do
        let(:advocate) { create(:external_user) }

        before do
          sign_in advocate.user
          post_feedback
        end

        it 'redirects to the users home' do
          expect(response).to redirect_to(external_users_root_url)
        end
      end

      context 'when the user is not signed in' do
        before { post_feedback }

        it 'redirects to the sign in page' do
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      context 'when determining the sender class' do
        before do
          allow(Settings).to receive(:zendesk_feedback_enabled?).and_return(true)
          allow(Feedback).to receive(:new).and_call_original
          post_feedback
        end

        it 'Uses the Zendesk sender' do
          expect(Feedback).to have_received(:new).with(hash_including(sender: ZendeskSender))
        end
      end
    end

    context 'when invalid' do
      let(:params) { { type: 'bug_report', event: nil } }

      before { post_feedback }

      it 'renders the new template' do
        expect(response).to render_template('feedback/bug_report')
      end
    end
  end
end
