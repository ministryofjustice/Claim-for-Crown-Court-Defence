# == Schema Information
#
# Table name: providers
#
#  id                        :integer          not null, primary key
#  name                      :string
#  firm_agfs_supplier_number :string
#  provider_type             :string
#  vat_registered            :boolean
#  uuid                      :uuid
#  api_key                   :uuid
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  roles                     :string
#

require 'rails_helper'
require 'support/shared_examples_for_claim_types'

RSpec.describe Provider, type: :model do
  let(:firm) { create(:provider, :firm) }
  let(:chamber) { create(:provider, :chamber) }
  let(:agfs_lgfs) { create(:provider, :agfs_lgfs) }

  it { should have_many(:external_users) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:provider_type) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity.with_message(:not_unique) }

  it { should delegate_method(:advocates).to(:external_users) }
  it { should delegate_method(:admins).to(:external_users) }

  context '#destroy' do
    before { create(:external_user, :advocate, provider: chamber) }
    it 'should destroy external users' do
      expect(ExternalUser.count).to eq 1
      expect(Provider.count).to eq 1
      expect { chamber.destroy }.to change { ExternalUser.count }.by(-1)
    end
  end

  context 'when chamber' do
    subject { chamber }

    it { should_not validate_presence_of(:firm_agfs_supplier_number) }
    it { should_not validate_uniqueness_of(:firm_agfs_supplier_number) }
  end

  context 'when firm' do
    let(:provider) { firm }

    context 'and changing the provider type to chamber' do
      subject(:change_to_chamber) do
        provider.provider_type = 'chamber'
        provider.save
      end

      context 'with LGFS role only' do
        let(:lgfs_supplier_numbers) { build_list(:supplier_number, 2) }
        let(:roles) { %w[lgfs] }
        let(:provider) { create(:provider, :firm, roles: roles, lgfs_supplier_numbers: lgfs_supplier_numbers) }

        it 'removes LGFS role' do
          expect { change_to_chamber }.to change { provider.reload.roles }.from(roles).to(%w[agfs])
        end

        it 'resets LGFS suppliers that are only required for firm' do
          expect { change_to_chamber }.to change { provider.reload.lgfs_supplier_numbers.count }.from(2).to(0)
        end
      end

      context 'with AGFS and LGFS roles' do
        let(:firm_agfs_supplier_number) { '123AH' }
        let(:lgfs_supplier_numbers) { build_list(:supplier_number, 2) }
        let(:roles) { %w[agfs lgfs] }
        let(:provider) { create(:provider, :firm, roles: roles, firm_agfs_supplier_number: firm_agfs_supplier_number, lgfs_supplier_numbers: lgfs_supplier_numbers) }

        it 'removes LGFS role' do
          expect { change_to_chamber }.to change { provider.reload.roles }.from(roles).to(%w[agfs])
        end

        it 'resets AGFS supplier number that is only required for firm' do
          expect { change_to_chamber }.to change { provider.reload.firm_agfs_supplier_number }.from(firm_agfs_supplier_number).to(nil)
        end

        it 'resets LGFS suppliers that are only required for firm' do
          expect { change_to_chamber }.to change { provider.reload.lgfs_supplier_numbers.count }.from(2).to(0)
        end
      end
    end
  end

  context 'ROLES' do
    it 'should have "agfs" and "lgfs"' do
      expect(Provider::ROLES).to match_array(%w(agfs lgfs))
    end
  end

  context '.set_api_key' do
    it 'should set API key at creation' do
      expect(chamber.api_key.present?).to eql true
    end

    it 'should set API key before validation' do
      chamber.api_key = nil
      expect(chamber.api_key.present?).to eql false
      expect(chamber).to be_valid
      expect(chamber.api_key.present?).to eql true
    end
  end

  context '.regenerate_api_key' do
    it 'should create a new api_key' do
      old_api_key = chamber.api_key
      expect { chamber.regenerate_api_key! }.to change { chamber.api_key }.from(old_api_key)
    end
  end

  describe '#firm?' do
    context 'when firm' do
      it 'should return true' do
        expect(firm.firm?).to eq(true)
      end
    end

    context 'when chamber' do
      it 'should return false' do
        expect(chamber.firm?).to eq(false)
      end
    end
  end

  describe '#chamber?' do
    context 'when firm' do
      it 'should return false' do
        expect(firm.chamber?).to eq(false)
      end
    end

    context 'when chamber' do
      it 'should return true' do
        expect(chamber.chamber?).to eq(true)
      end
    end
  end

  describe '.firms' do
    it 'returns only firms' do
      expect(Provider.firms).to match_array([firm])
    end
  end

  describe '.chambers' do
    it 'returns only chambers' do
      expect(Provider.chambers).to match_array([chamber])
    end
  end

  describe 'available_claim_types' do
    include_context 'claim-types object helpers'

    context 'for an AGFS provider' do
      let(:provider) { build :provider, :agfs }

      it 'returns the list of available claim types' do
        expect(provider.available_claim_types.map(&:to_s))
          .to match_array(agfs_claim_object_types)
      end
    end

    context 'for a LGFS provider' do
      let(:provider) { build :provider, :lgfs }

      it 'returns the list of available claim types for LGFS' do
        expect(provider.available_claim_types.map(&:to_s))
          .to match_array(lgfs_claim_object_types)
      end
    end

    context 'for a AGFS and LGFS provider' do
      let(:provider) { build(:provider, :agfs_lgfs) }

      it 'returns the list of all available claim types' do
        expect(provider.available_claim_types.map(&:to_s))
          .to match_array(all_claim_object_types)
      end
    end
  end

  context 'delegated external_user scopes/methods' do
    let!(:provider) { create(:provider) }
    let!(:advocate) { create(:external_user, :advocate) }
    let!(:admin_1) { create(:external_user, :admin) }
    let!(:admin_2) { create(:external_user, :admin) }

    before do
      provider.external_users << advocate
      provider.external_users << admin_1
      provider.external_users << admin_2
    end

    describe '#admins' do
      it 'only returns admins in the provider' do
        expect(provider.admins).to match_array([admin_1, admin_2])
      end
    end

    describe '#advocates' do
      it 'only returns advocates in the provider' do
        expect(provider.advocates).to match_array([advocate])
      end
    end
  end

  context 'AGFS supplier number validation for a chamber' do
    context 'for a blank supplier number' do
      it 'returns no errors' do
        chamber.firm_agfs_supplier_number = ''
        expect(chamber).to be_valid
      end
    end
  end

  context 'AGFS supplier number validation for a firm' do
    context 'for a blank supplier number' do
      it 'returns errors' do
        agfs_lgfs.firm_agfs_supplier_number = ''
        expect(agfs_lgfs).not_to be_valid
      end
    end

    context 'for a valid supplier number' do
      it 'returns no errors' do
        agfs_lgfs.firm_agfs_supplier_number = '2M462'
        expect(agfs_lgfs).to be_valid
      end
    end

    context 'for an invalid supplier number' do
      it 'returns errors' do
        agfs_lgfs.firm_agfs_supplier_number = 'XXX'
        expect(agfs_lgfs).not_to be_valid
        expect(agfs_lgfs.errors).to have_key(:firm_agfs_supplier_number)
      end
    end
  end

  context 'LGFS supplier number validation' do
    it 'validates the supplier numbers sub model for LGFS role' do
      expect_any_instance_of(SupplierNumberSubModelValidator).to receive(:validate_collection_for).with(firm, :lgfs_supplier_numbers)
      firm.valid?
    end

    it 'doesn\'t validate the supplier numbers sub model for AGFS role' do
      expect_any_instance_of(SupplierNumberSubModelValidator).not_to receive(:validate_collection_for)
      chamber.valid?
    end

    it 'returns error if supplier numbers is blank' do
      allow(firm).to receive(:lgfs_supplier_numbers).and_return([])
      expect(firm).to_not be_valid
      expect(firm.errors[:base]).to eq(['You must specify at least one LGFS supplier number'])
    end
  end

  describe '#agfs_supplier_numbers' do
    context 'agfs' do
      it 'returns an array of supplier numbers' do
        provider = create :provider, :agfs
        provider.external_users << create(:external_user, :advocate, supplier_number: '888AA')
        provider.external_users << create(:external_user, :advocate, supplier_number: '999BB')
        expect(provider.agfs_supplier_numbers).to match_array %w{888AA 999BB}
      end
    end

    context 'lgfs' do
      it 'returns an empty array' do
        provider = create :provider, :lgfs
        expect(provider.agfs_supplier_numbers).to be_empty
      end
    end
  end
end
