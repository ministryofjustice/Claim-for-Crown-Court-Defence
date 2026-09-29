require 'rails_helper'

RSpec.describe 'Multi-firm user links' do
  let(:external_user) { create(:external_user) }
  let(:user) { external_user.user }

  before { sign_in user }

  describe 'linked accounts navigation' do
    it 'is hidden for an ordinary external user' do
      get external_users_root_path

      expect(response.body).not_to include(external_users_multi_firm_user_links_path)
    end

    it 'is shown after multi-firm access is enabled' do
      user.update!(multi_firm_user: true)

      get external_users_root_path

      expect(response.body).to include(external_users_multi_firm_user_links_path)
    end
  end

  describe 'GET /external_users/multi_firm_user_links' do
    context 'when the user has enabled multi-firm access' do
      before { user.update!(multi_firm_user: true) }

      it 'renders successfully' do
        get external_users_multi_firm_user_links_path

        expect(response).to have_http_status(:success)
      end

      it 'renders the linked accounts heading' do
        get external_users_multi_firm_user_links_path

        heading = response.parsed_body.at_css('h1').text.strip
        expect(heading).to eq('Linked accounts')
      end

      it 'renders an existing linked account successfully' do
        create(:multi_firm_user_link, user:)

        get external_users_multi_firm_user_links_path

        expect(response).to have_http_status(:success)
      end

      it 'renders account removal as a delete action' do
        create(:multi_firm_user_link, user:)

        get external_users_multi_firm_user_links_path

        expect(response.body).to include('data-method="delete"')
      end
    end

    context 'when the user has not enabled multi-firm access' do
      it 'redirects to account settings' do
        get external_users_multi_firm_user_links_path

        expect(response).to redirect_to edit_external_users_admin_external_user_path(external_user)
      end

      it 'explains how to enable access' do
        get external_users_multi_firm_user_links_path

        expect(flash[:alert]).to eq('Enable multi-firm access in your account settings first.')
      end
    end
  end

  describe 'POST /external_users/multi_firm_user_links/links' do
    let(:linked_user) { create(:external_user).user }

    before { user.update!(multi_firm_user: true) }

    it 'links an account using its legacy credentials' do
      expect do
        post external_users_multi_firm_user_links_links_path,
             params: { multi_firm_user_linker: { email: linked_user.email, password: 'PasswordForTest' } }
      end.to change(MultiFirmUserLink, :count).by(1)
    end

    context 'with invalid credentials' do
      before do
        post external_users_multi_firm_user_links_links_path,
             params: { multi_firm_user_linker: { email: linked_user.email, password: 'wrong-password' } }
      end

      it 'returns an unprocessable response' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'shows a generic credential error' do
        expect(response.body).to include('The email or password is incorrect')
      end
    end
  end

  describe 'DELETE /external_users/multi_firm_user_links/links/:id' do
    it 'removes the signed-in user’s link' do
      user.update!(multi_firm_user: true)
      link = create(:multi_firm_user_link, user:)

      expect do
        delete external_users_multi_firm_user_links_link_path(link)
      end.to change(MultiFirmUserLink, :count).by(-1)
    end
  end
end
