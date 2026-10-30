require 'rails_helper'
require 'cancan/matchers'

RSpec.describe OmniauthCallbacksController, :aggregate_failures do
  let(:user) { create(:case_worker).user }

  describe 'GET #entra_mock' do
    before do
      allow(Settings).to receive(:dual_login_enabled?).and_return(true)
      user.login_route.update!(login_method: LoginRoute::ENTRA)
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = omniauth_auth(callback_email)
    end

    context 'when the Entra email matches the identified email' do
      let(:callback_email) { user.email.upcase }

      before { DualLogin.new(session).identify(user.email) }

      it 'signs the user in' do
        get :entra_mock
        expect(response).to redirect_to case_workers_root_path
      end

      context 'when SiLAS assigns the administrator role' do
        before { request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = ['LAA Administrator'] }

        it 'synchronises roles before choosing the landing page' do
          get :entra_mock
          expect(user.persona.reload.roles).to eq ['admin']
          expect(response).to redirect_to case_workers_admin_root_path
        end
      end

      context 'with an external user' do
        let(:user) { create(:external_user).user }

        before { request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = %w[Advocate Administrator] }

        it 'synchronises the external user roles and signs in' do
          get :entra_mock
          expect(user.persona.reload.roles).to eq %w[advocate admin]
          expect(response).to redirect_to external_users_root_path
        end
      end

      context 'when SiLAS supplies both advocate and litigator roles for an AGFS chamber' do
        let(:user) { create(:external_user, :advocate).user }

        before { request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = %w[Advocate Litigator] }

        it 'signs in with only the provider-permitted roles' do
          get :entra_mock
          expect(controller.current_user).to eq user
          expect(user.persona.reload.roles).to eq ['advocate']
          expect(response).to redirect_to external_users_root_path
        end

        it 'does not grant LGFS claim permissions' do
          get :entra_mock
          expect(Ability.new(controller.current_user)).not_to be_able_to(:create, Claim::LitigatorClaim)
          expect(Ability.new(controller.current_user)).to be_able_to(:create, Claim::AdvocateClaim)
        end
      end

      context 'when SiLAS supplies only litigator roles for an AGFS chamber' do
        let(:user) { create(:external_user, :advocate).user }

        before { request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = ['Litigator'] }

        it 'rejects sign-in with an authentication failure message' do
          get :entra_mock
          expect(controller.current_user).to be_nil
          expect(response).to redirect_to sign_in_path
          expect(flash[:alert]).to eq I18n.t('omniauth_callbacks.authentication_failed')
        end
      end
    end

    context 'when the Entra email differs from the identified email' do
      let(:callback_email) { 'other@example.com' }

      before { DualLogin.new(session).identify(user.email) }

      it 'does not create a user' do
        expect { get :entra_mock }.not_to change(User, :count)
      end

      it 'returns to sign in' do
        get :entra_mock
        expect(response).to redirect_to sign_in_path
      end

      it 'explains the email mismatch' do
        get :entra_mock
        expect(flash[:alert]).to eq I18n.t('omniauth_callbacks.email_mismatch')
      end

      it 'clears the identified email' do
        get :entra_mock
        expect(session[:dual_login]).to be_nil
      end
    end

    context 'without email identification' do
      let(:callback_email) { user.email }

      it 'returns to sign in' do
        get :entra_mock
        expect(response).to redirect_to sign_in_path
      end
    end
  end

  describe 'SiLAS role eligibility' do
    before do
      allow(Settings).to receive(:dual_login_enabled?).and_return(true)
      user.login_route.update!(login_method: LoginRoute::ENTRA)
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = omniauth_auth(user.email)
      DualLogin.new(session).identify(user.email)
    end

    personas = %i[case_worker external_user]
    invalid_roles = [[], nil, ['', ' ', nil], ['Unknown'], ['Super Administrator']]

    %i[entra_id entra_mock].each do |callback|
      personas.each do |persona|
        context "with an existing #{persona} administrator using #{callback}" do
          let(:user) { create(persona, :admin).user }

          invalid_roles.each do |roles|
            context "with #{roles.inspect} supplied roles" do
              before { request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = roles }

              it 'rejects sign-in with an authentication failure message' do
                get callback
                expect(controller.current_user).to be_nil
                expect(response).to redirect_to sign_in_path
                expect(flash[:alert]).to eq I18n.t('omniauth_callbacks.authentication_failed')
              end

              it 'clears identification without changing stored roles' do
                get callback
                expect(session[:dual_login]).to be_nil
                expect(user.persona.reload.roles).to eq ['admin']
              end
            end
          end

          context 'with roles applicable only to another persona' do
            before do
              roles = persona == :case_worker ? ['Advocate'] : ['Caseworker']
              request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = roles
            end

            it 'rejects sign-in' do
              get callback
              expect(controller.current_user).to be_nil
              expect(response).to redirect_to sign_in_path
              expect(flash[:alert]).to eq I18n.t('omniauth_callbacks.authentication_failed')
            end
          end

          context 'without the role claim' do
            it 'preserves existing sign-in behaviour and stored roles' do
              get callback
              expect(controller.current_user).to eq user
              expect(user.persona.reload.roles).to eq ['admin']
            end
          end
        end
      end
    end
  end

  describe 'role synchronisation validation' do
    let(:user) { create(:external_user, :admin, supplier_number:).user }
    let(:supplier_number) { nil }

    before do
      allow(Settings).to receive(:dual_login_enabled?).and_return(true)
      user.login_route.update!(login_method: LoginRoute::ENTRA)
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = omniauth_auth(user.email)
      request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = %w[Advocate Administrator]
      request.env['omniauth.auth'].extra.raw_info['LAA_ACCOUNTS'] = ['123AB']
      DualLogin.new(session).identify(user.email)
    end

    %i[entra_id entra_mock].each do |callback|
      context "when granting Advocate access through #{callback}" do
        it 'rejects sign-in gracefully when the supplier number is missing' do
          get callback
          expect(controller.current_user).to be_nil
          expect(response).to redirect_to sign_in_path
          expect(flash[:alert]).to eq I18n.t('omniauth_callbacks.authentication_failed')
        end

        it 'preserves stored roles and does not populate the supplier number from SiLAS' do
          get callback
          expect(user.persona.reload).to have_attributes(roles: ['admin'], supplier_number: nil)
        end

        it 'clears the failed identification' do
          get callback
          expect(session[:dual_login]).to be_nil
        end

        context 'with an invalid stored supplier number' do
          let(:supplier_number) { 'INVALID' }

          it 'rejects sign-in without changing stored data' do
            get callback
            expect(controller.current_user).to be_nil
            expect(response).to redirect_to sign_in_path
            expect(user.persona.reload).to have_attributes(roles: ['admin'], supplier_number: 'INVALID')
          end
        end

        context 'when the supplier number has been corrected in CCCD' do
          let(:supplier_number) { '456CD' }

          it 'synchronises roles and signs in without replacing the stored supplier number' do
            get callback
            expect(controller.current_user).to eq user
            expect(response).to redirect_to external_users_root_path
            expect(user.persona.reload).to have_attributes(roles: %w[advocate admin], supplier_number: '456CD')
          end
        end
      end
    end
  end

  describe 'existing account resolution' do
    before do
      allow(Settings).to receive(:dual_login_enabled?).and_return(true)
      user.login_route.update!(login_method: LoginRoute::ENTRA)
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = omniauth_auth(user.email.upcase)
      request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = %w[Advocate Caseworker]
      DualLogin.new(session).identify(user.email)
    end

    {
      case_worker: :case_workers_root_path,
      external_user: :external_users_root_path,
      super_admin: :super_admins_root_path
    }.each do |persona, destination|
      context "with an existing #{persona}" do
        let(:user) { create(persona).user }

        it 'signs in the existing account using its stored persona' do
          get :entra_id
          expect(controller.current_user).to eq user
          expect(response).to redirect_to public_send(destination)
        end
      end
    end

    it 'looks up the account once for eligibility and once for identity resolution' do
      allow(User).to receive(:find_by).and_call_original
      get :entra_id
      expect(User).to have_received(:find_by).with(email: user.email).twice
    end
  end

  describe 'callback eligibility' do
    before do
      allow(Settings).to receive_messages(feature_flags_enabled?: true, active_features: [], dual_login_enabled?: false)
      user.login_route.update!(login_method: LoginRoute::ENTRA, dual_login_tester: true)
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = omniauth_auth(user.email)
      DualLogin.new(session).identify(user.email)
    end

    %i[entra_id entra_mock].each do |callback|
      it "rejects revoked approval in #{callback} before changing roles or signing in" do # rubocop:disable RSpec/ExampleLength
        user.login_route.update!(dual_login_tester: false)
        request.env['omniauth.auth'].extra.raw_info['LAA_ROLES'] = ['LAA Administrator']
        get callback
        expect(response).to redirect_to sign_in_path
        expect(flash[:alert]).to eq I18n.t('session_routing.unavailable')
        expect(user.persona.reload.roles).to eq ['case_worker']
        expect(controller.current_user).to be_nil
        expect(session[:dual_login]).to be_nil
      end
    end

    it 'rejects route reassignment before signing in' do
      user.login_route.update!(login_method: LoginRoute::LEGACY)
      get :entra_id
      expect(controller.current_user).to be_nil
      expect(response).to redirect_to sign_in_path
    end
  end

  describe 'provider provisioning defaults' do
    subject(:provider) { controller.send(:find_or_create_provider_for_external_user, raw) }

    let(:raw) { { 'FIRM_NAME' => ' Example Firm ', 'LAA_ACCOUNTS' => %w[123AB 9a123b 8Z456Y] } }
    let(:auto_create_providers) { 'true' }

    around do |example|
      Dotenv.modify('AUTO_CREATE_PROVIDERS_FROM_SILAS' => auto_create_providers) { example.run }
    end

    it 'persists LGFS firm defaults and normalised supplier numbers' do
      expect(provider.reload).to have_attributes(
        name: 'Example Firm', provider_type: 'firm', roles: ['lgfs'],
        vat_registered: true, firm_agfs_supplier_number: nil
      )
      expect(provider.lgfs_supplier_numbers.reload.pluck(:supplier_number)).to contain_exactly('9A123B', '8Z456Y')
    end

    context 'when automatic provider creation is disabled' do
      let(:auto_create_providers) { 'false' }

      it 'rejects the request without creating a provider' do
        expect do
          expect { provider }.to raise_error(ArgumentError, 'No provider found for FIRM_NAME: Example Firm')
        end.not_to change(Provider, :count)
      end
    end

    context 'when matching an existing provider by name' do
      let!(:existing_provider) { create(:provider, name: 'Example & Firm') }
      let(:raw) { super().merge('FIRM_NAME' => ' Example & Firm ') }
      let(:auto_create_providers) { 'false' }

      it 'reuses the exact name match without creating a provider' do
        expect { expect(provider).to eq existing_provider }.not_to change(Provider, :count)
      end

      it 'queries the name column directly' do
        allow(Provider).to receive(:find_by).and_call_original
        provider
        expect(Provider).to have_received(:find_by).with(name: 'Example & Firm')
      end

      ['EXAMPLE & FIRM', 'Example and Firm', 'Example & Firm.', 'Example  & Firm'].each do |firm_name|
        context "with the non-identical name #{firm_name.inspect}" do
          let(:raw) { super().merge('FIRM_NAME' => firm_name) }

          it 'rejects the request without creating a provider' do
            expect do
              expect { provider }.to raise_error(ArgumentError, "No provider found for FIRM_NAME: #{firm_name}")
            end.not_to change(Provider, :count)
          end
        end
      end
    end

    context 'without a firm name' do
      let(:raw) { super().merge('FIRM_NAME' => ' ') }

      it 'rejects the missing name' do
        expect { provider }.to raise_error(ArgumentError, 'Missing FIRM_NAME in auth payload')
      end
    end

    context 'without an LGFS supplier number' do
      let(:raw) { super().merge('LAA_ACCOUNTS' => ['123AB']) }

      it 'propagates validation errors without creating a provider' do
        expect do
          expect { provider }.to raise_error(ActiveRecord::RecordInvalid)
        end.not_to change(Provider, :count)
      end
    end
  end

  def omniauth_auth(email)
    OmniAuth::AuthHash.new(info: { email: email }, extra: { raw_info: {} })
  end
end
