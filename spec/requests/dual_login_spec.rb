require 'rails_helper'

# Keep multi-request state transitions together in these regression scenarios.
# rubocop:disable RSpec/ExampleLength
RSpec.describe 'Dual-login pilot', :aggregate_failures do
  let(:password) { 'Password123456!' }
  let(:user) { create(:case_worker, user: build(:user, password: password, password_confirmation: password)).user }

  before do
    allow(Settings).to receive_messages(feature_flags_enabled?: true, active_features: [], dual_login_enabled?: false)
  end

  def identify
    post dual_login_path, params: { email: user.email }
  end

  def submit_password(path = user_session_path, email: user.email, secret: password)
    post path, params: { user: { email: email, password: secret } }
  end

  def expect_rejection
    expect(response).to redirect_to sign_in_path
    expect(flash[:alert]).to eq 'Unable to continue with this sign-in method. Use the standard sign-in page.'
  end

  it 'shows original password login and a public pilot link by default' do
    [sign_in_path, unauthenticated_root_path].each do |path|
      get path
      expect(Capybara.string(response.body)).to have_field('Password')
      expect(Capybara.string(response.body)).to have_link('Try the new sign-in (approved testers only)',
                                                          href: dual_login_path)
    end
    get dual_login_path
    expect(response.body).to include('This sign-in page is for approved testers only.')
    expect(Capybara.string(response.body)).to have_no_field('Password')
  end

  it 'authenticates directly using original credentials without tester approval' do
    submit_password(sign_in_path)
    expect(response).to redirect_to case_workers_root_path
  end

  it 'shows the pilot-only message in a green notification banner' do
    get dual_login_path
    expect(response.parsed_body.at_css('.govuk-notification-banner__title')&.text&.strip).to eq 'Notice'
    expect(Capybara.string(response.body)).to have_css(
      '.govuk-notification-banner--success',
      text: 'This sign-in page is for approved testers only.'
    )
  end

  [
    ['/users/sign_in', 'Try the new sign-in (approved testers only)', '/users/dual_login'],
    ['/users/dual_login', 'Back to standard sign-in', '/users/sign_in']
  ].each do |page_path, label, destination|
    it "places #{label} beneath terms and conditions with a separate line of spacing" do
      get page_path
      link = response.parsed_body.at_xpath(
        "//ul[li/a[@href='#{tandcs_page_path}']]/following-sibling::p[1]" \
        "[contains(@class, 'govuk-!-margin-top-6')]/a"
      )
      expect(link&.text).to eq label
      expect(link&.[]('href')).to eq destination
    end
  end

  [false, true].product(%i[existing unknown]).each do |rollout, account|
    it "preserves the password recovery confirmation for an #{account} account with public rollout #{rollout}" do
      allow(Settings).to receive(:dual_login_enabled?).and_return(rollout)
      user.login_route.update!(dual_login_tester: true)
      identify
      follow_redirect!
      get new_user_password_path
      email = account == :existing ? user.email : 'unknown@example.com'
      post user_password_path, params: { user: { email: email } }

      expect(response).to redirect_to sign_in_path
      follow_redirect!
      follow_redirect! if rollout
      expect(response).to have_http_status(:ok)
      expect(Capybara.string(response.body)).to have_text(I18n.t('devise.passwords.send_paranoid_instructions'))
      expect(flash[:alert]).to be_nil
      expect(response.body).not_to include(I18n.t('session_routing.unavailable'))
      expect(request.env['warden'].user).to be_nil

      get new_user_session_path
      expect_rejection
    end
  end

  [false, true].each do |rollout|
    it "signs out cleanly in development with public rollout #{rollout}" do
      allow(Settings).to receive(:dual_login_enabled?).and_return(rollout)
      sign_in user
      Dotenv.modify('ENV' => 'dev') do
        delete destroy_user_session_path
        expect(response).to redirect_to sign_in_path
        follow_redirect!
        follow_redirect! if rollout
        expect(response).to have_http_status(:ok)
        expect(flash[:alert]).to be_nil
        expect(response.body).not_to include(I18n.t('session_routing.unavailable'))
        expect(request.env['warden'].user).to be_nil
      end
    end
  end

  it 'keeps original credential login available for Entra-assigned accounts during the pilot' do
    user.login_route.update!(login_method: LoginRoute::ENTRA)
    submit_password(sign_in_path)
    expect(response).to redirect_to case_workers_root_path
  end

  it 'renders a failed original login and permits retry without an identification loop' do
    submit_password(sign_in_path, secret: 'wrong')
    expect(response).to have_http_status(:ok)
    expect(Capybara.string(response.body)).to have_field('Password')
    expect(response.body).to include("action=\"#{sign_in_path}\"")
    submit_password(sign_in_path)
    expect(response).to redirect_to case_workers_root_path
  end

  it 'gives the same rejection to unknown, unapproved and missing-route accounts' do
    [user.email, 'unknown@example.com'].each do |email|
      post dual_login_path, params: { email: email }
      expect_rejection
    end
    user.login_route.destroy!
    identify
    expect_rejection
  end

  it 'rejects direct new password GET and POST requests' do
    get new_user_session_path
    expect_rejection
    submit_password
    expect_rejection
  end

  it 'does not treat formatted new-password URLs as original login' do
    get "#{new_user_session_path}.html"
    expect_rejection
    submit_password("#{user_session_path}.html")
    expect_rejection
  end

  context 'with an approved tester' do
    before { user.login_route.update!(dual_login_tester: true) }

    it 'requires the identified account password despite a substituted email' do
      other = create(:case_worker).user
      identify
      submit_password(email: other.email, secret: 'PasswordForTest')
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("action=\"#{user_session_path}\"", user.email)
      submit_password(email: other.email)
      expect(response).to redirect_to case_workers_root_path
      expect(request.env['warden'].user.id).to eq user.id
    end

    it 'rejects revocation after identification and clears the flow' do
      identify
      user.login_route.update!(dual_login_tester: false)
      submit_password
      expect_rejection
      user.login_route.update!(dual_login_tester: true)
      submit_password
      expect_rejection
    end

    it 'rejects a login method change after identification' do
      identify
      user.login_route.update!(login_method: LoginRoute::ENTRA)
      submit_password
      expect_rejection
    end

    it 'rejects a deleted route after identification' do
      identify
      user.login_route.destroy!
      submit_password
      expect_rejection
    end

    it 'clears pilot identity when returning to original login' do
      identify
      get sign_in_path
      submit_password
      expect_rejection
      submit_password(sign_in_path)
      expect(response).to redirect_to case_workers_root_path
    end

    it 'clears identity when restarting with invalid input' do
      identify
      post dual_login_path, params: { email: '' }
      submit_password
      expect_rejection
    end

    it 'clears identification when a signed-out visitor requests logout' do
      identify
      delete destroy_user_session_path
      submit_password
      expect_rejection
    end

    it 'clears identification when starting password recovery' do
      identify
      get new_user_password_path
      submit_password
      expect_rejection
    end

    it 'supports recovery and logout without retaining pilot approval state' do
      identify
      get new_user_password_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("href=\"#{sign_in_path}\"")
      get sign_in_path
      submit_password(sign_in_path)
      delete destroy_user_session_path
      submit_password
      expect_rejection
    end
  end

  context 'when public rollout is enabled' do
    before { allow(Settings).to receive(:dual_login_enabled?).and_return(true) }

    it 'selects email-first login without pilot messaging and blocks direct credential posts' do
      get sign_in_path
      expect(response).to redirect_to dual_login_path
      follow_redirect!
      expect(response.body).not_to include('approved testers only')
      expect(Capybara.string(response.body)).to have_no_field('Password')
      submit_password(sign_in_path)
      expect(response).to redirect_to dual_login_path
    end

    it 'allows unapproved accounts through the identified password step' do
      identify
      submit_password
      expect(response).to redirect_to case_workers_root_path
    end

    it 'rechecks approval when rollout is disabled mid-flow' do
      identify
      allow(Settings).to receive(:dual_login_enabled?).and_return(false)
      submit_password
      expect_rejection
    end

    it 'returns to restricted pilot mode when the master switch is disabled' do
      allow(Settings).to receive(:feature_flags_enabled?).and_return(false)
      get sign_in_path
      expect(Capybara.string(response.body)).to have_field('Password')
      identify
      expect_rejection
    end
  end
end
# rubocop:enable RSpec/ExampleLength
