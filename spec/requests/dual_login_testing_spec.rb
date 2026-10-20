require 'rails_helper'

# Exercise approval changes and their persisted results as one request scenario.
# rubocop:disable RSpec/ExampleLength
RSpec.describe 'Dual-login tester management', :aggregate_failures do
  let(:account) { create(:case_worker).user }
  let(:path) { super_admins_dual_login_testing_index_path }
  let(:method_path) { update_login_method_super_admins_dual_login_testing_path(account) }

  context 'when signed in as a superadmin' do
    before { sign_in create(:super_admin).user }

    it 'finds an existing account by normalized email and offers approval' do
      get path, params: { email: " #{account.email.upcase} " }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(account.email, 'Approve testing')
    end

    it 'approves and revokes without changing the login method' do
      account.login_route.update!(login_method: LoginRoute::ENTRA)
      patch super_admins_dual_login_testing_path(account), params: { dual_login_tester: 'true', login_method: 'legacy' }
      expect(response).to redirect_to "#{path}?email=#{ERB::Util.url_encode(account.email)}"
      expect(account.login_route.reload).to be_dual_login_tester
      expect(account.login_route.login_method).to eq LoginRoute::ENTRA

      patch super_admins_dual_login_testing_path(account), params: { dual_login_tester: 'false' }
      expect(account.login_route.reload).not_to be_dual_login_tester
      expect(account.login_route.login_method).to eq LoginRoute::ENTRA
    end

    it 'explains that a missing route must be repaired separately' do
      account.login_route.destroy!
      get path, params: { email: account.email }
      expect(response.body).to include('no login route')
      expect(response.body).not_to include('Approve testing')

      patch super_admins_dual_login_testing_path(account), params: { dual_login_tester: 'true' }
      expect(account.reload.login_route).to be_nil
      expect(flash[:alert]).to include('no login route')
    end

    it 'reports an unknown account' do
      get path, params: { email: 'unknown@example.com' }
      expect(response.body).to include('No account found')
    end

    it 'rejects invalid approval values rather than revoking implicitly' do
      account.login_route.update!(dual_login_tester: true)
      patch super_admins_dual_login_testing_path(account), params: { dual_login_tester: 'invalid' }
      expect(response).to have_http_status(:bad_request)
      expect(account.login_route.reload).to be_dual_login_tester
    end

    it 'requires a CSRF token to change approval', :allow_forgery_protection do
      patch super_admins_dual_login_testing_path(account), params: { dual_login_tester: 'true' }
      expect(account.login_route.reload).not_to be_dual_login_tester
      expect(response).to have_http_status(:redirect)
    end

    it 'accepts the token from the tester-management form', :allow_forgery_protection do
      get path, params: { email: account.email }
      token = response.parsed_body.at_css('input[name="authenticity_token"]')['value']
      patch super_admins_dual_login_testing_path(account),
            params: { dual_login_tester: 'true', authenticity_token: token }
      expect(account.login_route.reload).to be_dual_login_tester
    end

    it 'surfaces validation failures without reporting success' do
      # Simulate invalid persisted routing data so the update fails model validation.
      account.login_route.update_column(:login_method, 'invalid') # rubocop:disable Rails/SkipsModelValidations
      patch super_admins_dual_login_testing_path(account), params: { dual_login_tester: 'true' }
      expect(flash[:alert]).to include('Unable to update tester approval')
      expect(flash[:notice]).to be_nil
      expect(account.login_route.reload).not_to be_dual_login_tester
    end
  end

  context 'when managing login methods as a superadmin' do
    before { sign_in create(:super_admin).user }

    [false, true].each do |approved|
      it "changes between legacy and Entra without changing approval #{approved}" do
        account.login_route.update!(dual_login_tester: approved)
        patch method_path, params: { login_method: 'entra', dual_login_tester: !approved }
        expect(response).to redirect_to "#{path}?email=#{ERB::Util.url_encode(account.email)}"
        expect(account.login_route.reload.login_method).to eq 'entra'
        expect(account.login_route.dual_login_tester?).to eq approved

        patch method_path, params: { login_method: 'legacy' }
        expect(account.login_route.reload.login_method).to eq 'legacy'
        expect(account.login_route.dual_login_tester?).to eq approved
      end
    end

    it 'shows the current method and both choices' do
      account.login_route.update!(login_method: 'entra')
      get path, params: { email: account.email }
      page = Capybara.string(response.body)
      expect(page).to have_checked_field('Entra')
      expect(page).to have_unchecked_field('Legacy')
      expect(page).to have_button('Save login method')
    end

    it 'rejects invalid login methods without changing routing' do
      patch method_path, params: { login_method: 'invalid' }
      expect(response).to have_http_status(:bad_request)
      expect(account.login_route.reload.login_method).to eq 'legacy'
    end

    it 'reports a missing route rather than creating one' do
      account.login_route.destroy!
      patch method_path, params: { login_method: 'entra' }
      expect(flash[:alert]).to include('no login route')
      expect(account.reload.login_route).to be_nil
    end

    it 'requires a CSRF token to change the method', :allow_forgery_protection do
      patch method_path, params: { login_method: 'entra' }
      expect(account.login_route.reload.login_method).to eq 'legacy'
      expect(response).to have_http_status(:redirect)
    end

    it 'accepts the token from the login-method form', :allow_forgery_protection do
      get path, params: { email: account.email }
      token = response.parsed_body.at_css("form[action='#{method_path}'] input[name='authenticity_token']")['value']
      patch method_path, params: { login_method: 'entra', authenticity_token: token }
      expect(account.login_route.reload.login_method).to eq 'entra'
      expect(flash[:notice]).to eq 'Login method updated. Tester approval has not changed.'
    end
  end

  [nil, :case_worker, :external_user].each do |persona|
    context "when accessing as #{persona || 'an anonymous visitor'}" do
      before { sign_in create(persona).user if persona }

      it 'cannot view or change tester approval' do
        get path, params: { email: account.email }
        expect(response).to have_http_status(:redirect)
        patch super_admins_dual_login_testing_path(account), params: { dual_login_tester: 'true' }
        expect(response).to have_http_status(:redirect)
        expect(account.login_route.reload).not_to be_dual_login_tester
      end

      it 'cannot change the login method' do
        patch method_path, params: { login_method: 'entra' }
        expect(response).to have_http_status(:redirect)
        expect(account.login_route.reload.login_method).to eq 'legacy'
      end
    end
  end
end
# rubocop:enable RSpec/ExampleLength
