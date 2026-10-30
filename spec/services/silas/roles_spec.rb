require 'rails_helper'

RSpec.describe Silas::Roles do
  subject(:role_mapping) { described_class.new(raw) }

  let(:raw) { { 'LAA_ROLES' => laa_roles } }
  let(:laa_roles) { [] }

  describe '#empty?' do
    context 'with only blank roles' do
      let(:laa_roles) { ['', ' ', nil] }

      it { is_expected.to be_empty }
    end

    context 'without the role claim' do
      let(:raw) { {} }

      it { is_expected.to be_empty }
    end

    context 'with unrecognised roles' do
      let(:laa_roles) { ['Unknown'] }

      it { is_expected.not_to be_empty }
    end
  end

  describe '#case_worker_roles' do
    let(:laa_roles) do
      [' Caseworker ', 'Provider Management', 'LAA Administrator', 'Caseworker', 'Advocate', 'Unknown', '', nil]
    end

    it 'normalises, maps and deduplicates only internal roles' do
      expect(role_mapping.case_worker_roles).to eq %w[case_worker provider_management admin]
    end

    context 'with a single string role' do
      let(:laa_roles) { ' Caseworker ' }

      it 'accepts the role without an array' do
        expect(role_mapping.case_worker_roles).to eq ['case_worker']
      end
    end

    context 'without recognised internal roles' do
      let(:laa_roles) { %w[Advocate Unknown] }

      it 'returns no roles' do
        expect(role_mapping.case_worker_roles).to be_empty
      end
    end
  end

  describe '#external_user_roles' do
    let(:laa_roles) { [' Advocate ', 'Litigator', 'Administrator', 'Advocate', 'Caseworker', 'Unknown', '', nil] }

    it 'normalises, maps and deduplicates only external roles' do
      expect(role_mapping.external_user_roles).to eq %w[advocate litigator admin]
    end

    ['Advocate Admin', 'Litigator Admin'].each do |role|
      context "with the legacy #{role} role" do
        let(:laa_roles) { [role] }

        it 'maps the alias to the administrator role' do
          expect(role_mapping.external_user_roles).to eq ['admin']
        end
      end
    end

    context 'without recognised external roles' do
      let(:laa_roles) { %w[Caseworker Unknown] }

      it 'returns no roles' do
        expect(role_mapping.external_user_roles).to be_empty
      end
    end
  end

  describe '#persona_type' do
    [
      [%w[Caseworker Advocate] + ['Super Administrator'], 'SuperAdmin'],
      [%w[Caseworker Advocate], 'ExternalUser'],
      [['Caseworker'], 'CaseWorker'],
      [['Unknown'], nil],
      [[], nil]
    ].each do |roles, persona_type|
      context "with #{roles.inspect} roles" do
        let(:laa_roles) { roles }

        it 'preserves persona precedence' do
          expect(role_mapping.persona_type).to eq persona_type
        end
      end
    end
  end

  describe '#sync!' do
    let(:user) { create(:case_worker).user }
    let(:laa_roles) { ['Caseworker', 'Advocate', 'LAA Administrator', 'Administrator'] }

    {
      case_worker: %w[case_worker admin],
      external_user: %w[advocate admin]
    }.each do |persona, expected_roles|
      context "with a #{persona}" do
        let(:user) { create(persona).user }

        it 'persists only the roles appropriate to the existing persona' do
          role_mapping.sync!(user)
          expect(user.persona.reload.roles).to eq expected_roles
        end
      end
    end

    {
      agfs: %w[advocate admin],
      lgfs: %w[litigator admin],
      agfs_lgfs: %w[advocate litigator admin]
    }.each do |provider_trait, expected_roles|
      context "with an #{provider_trait} provider" do
        let(:provider) { create(:provider, provider_trait) }
        let(:user) { create(:external_user, provider:, roles: ['admin']).user }
        let(:laa_roles) { %w[Advocate Litigator Administrator] }

        it 'persists only roles permitted by the provider' do
          role_mapping.sync!(user)
          expect(user.persona.reload.roles).to eq expected_roles
        end
      end
    end

    { agfs: ['Litigator'], lgfs: ['Advocate'] }.each do |provider_trait, roles|
      context "with only roles outside the #{provider_trait} provider entitlements" do
        let(:provider) { create(:provider, provider_trait) }
        let(:user) { create(:external_user, :admin, provider:).user }
        let(:laa_roles) { roles }

        it 'rejects synchronisation without changing stored roles', :aggregate_failures do
          expect do
            expect { role_mapping.sync!(user) }.to raise_error(described_class::NoApplicableRoles)
          end.not_to change { user.persona.reload.roles }
        end
      end
    end

    context 'with a previously stored role outside the provider entitlements' do
      let(:user) { create(:external_user, roles: %w[advocate litigator]).user }
      let(:laa_roles) { %w[Advocate Litigator] }

      it 'removes the role no longer permitted by the provider' do
        role_mapping.sync!(user)
        expect(user.persona.reload.roles).to eq ['advocate']
      end
    end

    context 'with unchanged roles in a different order' do
      before do
        user.persona.update!(roles: %w[admin case_worker])
        allow(user.persona).to receive(:update!).and_call_original
      end

      it 'does not write to the database' do
        role_mapping.sync!(user)
        expect(user.persona).not_to have_received(:update!)
      end
    end

    context 'without the role claim' do
      let(:raw) { {} }

      it 'preserves the current roles' do
        expect { role_mapping.sync!(user) }.not_to change { user.persona.reload.roles }
      end
    end

    [[], nil, ['', ' ', nil], ['Unknown'], ['Advocate'], ['Super Administrator']].each do |roles|
      context "with #{roles.inspect} incoming roles" do
        let(:laa_roles) { roles }

        it 'rejects synchronisation without changing the current roles', :aggregate_failures do
          expect do
            expect { role_mapping.sync!(user) }.to raise_error(
              described_class::NoApplicableRoles, 'No applicable roles found in LAA_ROLES'
            )
          end.not_to change { user.persona.reload.roles }
        end
      end
    end

    context 'when updating roles fails' do
      before do
        allow(user.persona).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(user.persona))
      end

      it 'propagates the error' do
        expect { role_mapping.sync!(user) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with a superadmin' do
      let(:user) { create(:super_admin).user }
      let(:laa_roles) { %w[Caseworker Advocate] }

      it 'does not update the persona' do
        expect { role_mapping.sync!(user) }.not_to change { user.persona.reload.updated_at }
      end
    end

    context 'without a persona' do
      it 'does not try to synchronise roles' do
        expect { role_mapping.sync!(User.new) }.not_to raise_error
      end
    end
  end
end
