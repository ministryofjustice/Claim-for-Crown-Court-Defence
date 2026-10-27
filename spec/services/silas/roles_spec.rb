require 'rails_helper'

RSpec.describe Silas::Roles do
  subject(:role_mapping) { described_class.new(raw) }

  let(:raw) { { 'LAA_ROLES' => laa_roles } }
  let(:laa_roles) { [] }

  describe '#empty?' do
    [nil, [], ['', ' ', nil]].each do |roles|
      context "with #{roles.inspect} roles" do
        let(:laa_roles) { roles }

        it { is_expected.to be_empty }
      end
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
        let(:laa_roles) { [role, 'Administrator'] }

        it 'retains the administrator mapping without duplicates' do
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
    unmapped_role_sets = [[], ['Unknown'], ['Super Administrator']]

    {
      case_worker: %w[case_worker admin],
      external_user: %w[advocate admin]
    }.each do |persona, expected_roles|
      context "with a #{persona}" do
        let(:user) { create(persona).user }
        let(:laa_roles) { ['Caseworker', 'Advocate', 'LAA Administrator', 'Administrator'] }

        it 'persists only the roles appropriate to the existing persona' do
          role_mapping.sync!(user)
          expect(user.persona.reload.roles).to eq expected_roles
        end

        context 'with unchanged roles in a different order' do
          before do
            user.persona.update!(roles: expected_roles.reverse)
            allow(user.persona).to receive(:update!).and_call_original
          end

          it 'does not write to the database' do
            role_mapping.sync!(user)
            expect(user.persona).not_to have_received(:update!)
          end
        end

        unmapped_role_sets.each do |roles|
          context "with #{roles.inspect} incoming roles" do
            let(:laa_roles) { roles }

            it 'preserves the current roles' do
              expect { role_mapping.sync!(user) }.not_to change { user.persona.reload.roles }
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
