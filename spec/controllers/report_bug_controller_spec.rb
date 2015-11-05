require 'rails_helper'

RSpec.describe BugReportController, type: :controller do

  describe "GET #new" do
    before do
      get :new
    end

    it 'assigns a new @feedback' do
      expect(assigns(:bug_report)).to_not be_nil
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "renders the new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    before do
      allow(ZendeskAPI::Ticket).to receive(:create!).and_return(true)
    end

    let(:params) do
      { event: 'Testing',
        outcome: 'Hello World'
       }
    end

    context 'when valid' do
      context 'and user signed in' do
        let(:advocate) { create(:advocate) }

        before do
          sign_in advocate.user
        end

        it "redirects to the users home" do
          post :create, bug_report: params
          expect(response).to redirect_to(advocates_root_url)
        end
      end

      context 'and no user signed in' do
        it "redirects to the sign in page" do
          post :create, bug_report: params
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end

    context 'when invalid' do
      let(:params) do
        { event: nil,
          outcome: nil
        }
      end

      it "renders the new template" do
        post :create, bug_report: params
        expect(response).to render_template(:new)
      end
    end
  end

end
