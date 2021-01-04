require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  describe 'GET #new' do
    let(:params) { {} }

    before { get :new, params: params }

    it 'assigns a new @feedback' do
      expect(assigns(:feedback)).to_not be_nil
    end

    it 'returns http success' do
      expect(response).to be_successful
    end

    context 'feedback' do
      let(:params) { { type: 'feedback' } }

      it 'renders the feedback template' do
        expect(response).to render_template('feedback/feedback')
      end
    end

    context 'bug report' do
      let(:params) { { type: 'bug_report' } }

      it 'renders the bug report template' do
        expect(response).to render_template('feedback/bug_report')
      end
    end
  end

  describe 'POST #create' do
    before do
      allow(ZendeskAPI::Ticket).to receive(:create!).and_return(true)
    end

    context 'feedback' do
      let(:params) do
        { type: 'feedback', rating: '3' }
      end

      context 'when valid' do
        context 'and user signed in' do
          let(:advocate) { create(:external_user) }

          before do
            sign_in advocate.user
          end

          it 'redirects to the users home' do
            post :create, params: { feedback: params }
            expect(response).to redirect_to(external_users_root_url)
          end
        end

        context 'and no user signed in' do
          it 'redirects to the sign in page' do
            post :create, params: { feedback: params }
            expect(response).to redirect_to(new_user_session_url)
          end
        end

        it 'calls the GoogleAnalytics::Api' do
          expect(GoogleAnalytics::Api).to receive(:event).and_return(true)
          post :create, params: { feedback: params }
        end
      end

      context 'when invalid' do
        let(:params) do
          { type: 'feedback', rating: nil }
        end

        it 'renders the new template' do
          post :create, params: { feedback: params }
          expect(response).to render_template('feedback/feedback')
        end
      end
    end

    context 'bug report' do
      let(:params) do
        { type: 'bug_report', case_number: 'XXXX', event: 'lorem', outcome: 'ipsum' }
      end

      context 'when valid' do
        context 'and user signed in' do
          let(:advocate) { create(:external_user) }

          before do
            sign_in advocate.user
          end

          it 'redirects to the users home' do
            post :create, params: { feedback: params }
            expect(response).to redirect_to(external_users_root_url)
          end
        end

        context 'and no user signed in' do
          it 'redirects to the sign in page' do
            post :create, params: { feedback: params }
            expect(response).to redirect_to(new_user_session_url)
          end
        end
      end

      context 'when invalid' do
        let(:params) do
          { type: 'bug_report', event: nil }
        end

        it 'renders the new template' do
          post :create, params: { feedback: params }
          expect(response).to render_template('feedback/bug_report')
        end
      end
    end
  end
end
