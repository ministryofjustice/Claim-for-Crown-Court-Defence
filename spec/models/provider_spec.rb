require 'support/shared_examples_for_claim_types'

RSpec.describe Provider do
  let(:firm) { create(:provider, :firm) }
  let(:chamber) { create(:provider, :chamber) }
  let(:agfs_lgfs) { create(:provider, :agfs_lgfs) }

  it { is_expected.to have_many(:external_users).dependent(:destroy) }
  it { is_expected.to have_many(:claims).conditions(deleted_at: nil).through(:external_users) }
  it { is_expected.to have_many(:claims_created).conditions(deleted_at: nil).through(:external_users) }
  it { is_expected.to have_many(:lgfs_supplier_numbers).class_name('SupplierNumber').dependent(:destroy) }

  it { is_expected.to accept_nested_attributes_for(:lgfs_supplier_numbers).allow_destroy(true) }

  it { is_expected.to validate_presence_of(:provider_type).with_message('Choose a provider type') }
  it { is_expected.to validate_presence_of(:name).with_message('Enter a provider name') }
  it { is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity.with_message('Enter a provider name not already taken') }

  context 'when validating an lgfs only firm' do
    subject(:provider) { firm }

    it { is_expected.to validate_absence_of(:firm_agfs_supplier_number).with_message('Remove the supplier number') }
  end

  context 'when validating an agfs firm' do
    subject(:provider) { agfs_lgfs }

    it { is_expected.to validate_presence_of(:firm_agfs_supplier_number).with_message('Enter a supplier number') }
  end

  context 'when validating a chamber' do
    subject(:provider) { chamber }

    it { is_expected.not_to validate_presence_of(:firm_agfs_supplier_number) }
    it { is_expected.not_to validate_uniqueness_of(:firm_agfs_supplier_number) }
  end

  it { is_expected.to delegate_method(:advocates).to(:external_users) }
  it { is_expected.to delegate_method(:admins).to(:external_users) }

  describe '#destroy' do
    before { create(:external_user, :advocate, provider: chamber) }

    it 'destroys external users' do
      expect { chamber.destroy }.to change(ExternalUser, :count).by(-1)
    end

    it 'destroys provider' do
      expect { chamber.destroy }.to change(Provider, :count).by(-1)
    end
  end

  context 'when changing the provider type to chamber' do
    subject(:change_to_chamber) do
      provider.provider_type = 'chamber'
      provider.save
    end

    let(:provider) { firm }

    context 'with LGFS role only' do
      let(:lgfs_supplier_numbers) { build_list(:supplier_number, 2) }
      let(:roles) { %w[lgfs] }
      let(:provider) { create(:provider, :firm, roles:, lgfs_supplier_numbers:) }

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
      let(:provider) { create(:provider, :firm, roles:, firm_agfs_supplier_number:, lgfs_supplier_numbers:) }

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

  context '::ROLES' do
    it 'has "agfs" and "lgfs"' do
      expect(Provider::ROLES).to match_array(%w[agfs lgfs])
    end
  end

  describe '.set_api_key' do
    it 'sets API key at creation' do
      expect(chamber.api_key.present?).to be true
    end

    context 'when validating with nil #api_key' do
      before { chamber.api_key = nil }

      it { expect { chamber.validate }.to change(chamber, :api_key) }
    end
  end

  describe '.regenerate_api_key' do
    it 'creates a new api_key' do
      old_api_key = chamber.api_key
      expect { chamber.regenerate_api_key! }.to change(chamber, :api_key).from(old_api_key)
    end
  end

  describe '#firm?' do
    context 'when firm' do
      it 'returns true' do
        expect(firm.firm?).to be(true)
      end
    end

    context 'when chamber' do
      it 'returns false' do
        expect(chamber.firm?).to be(false)
      end
    end
  end

  describe '#chamber?' do
    context 'when firm' do
      it 'returns false' do
        expect(firm.chamber?).to be(false)
      end
    end

    context 'when chamber' do
      it 'returns true' do
        expect(chamber.chamber?).to be(true)
      end
    end
  end

  describe '.firms' do
    it 'returns only firms' do
      expect(Provider.firms).to contain_exactly(firm)
    end
  end

  describe '.chambers' do
    it 'returns only chambers' do
      expect(Provider.chambers).to contain_exactly(chamber)
    end
  end

  describe '#available_claim_types' do
    include_context 'claim-types object helpers'

    context 'with an AGFS provider' do
      let(:provider) { build(:provider, :agfs) }

      it 'returns the list of available claim types' do
        expect(provider.available_claim_types.map(&:to_s))
          .to match_array(agfs_claim_object_types)
      end
    end

    context 'with a LGFS provider' do
      let(:provider) { build(:provider, :lgfs) }

      it 'returns the list of available claim types for LGFS' do
        expect(provider.available_claim_types.map(&:to_s))
          .to match_array(lgfs_claim_object_types)
      end
    end

    context 'with an AGFS and LGFS provider' do
      let(:provider) { build(:provider, :agfs_lgfs) }

      it 'returns the list of all available claim types' do
        expect(provider.available_claim_types.map(&:to_s))
          .to match_array(all_claim_object_types)
      end
    end
  end

  context 'delegated external_user scopes/methods' do
    let(:provider) { create(:provider) }
    let(:advocate) { create(:external_user, :advocate) }
    let(:admins) { create_list(:external_user, 2, :admin) }

    before do
      provider.external_users << advocate
      provider.external_users += admins
    end

    describe '#admins' do
      it 'only returns admins in the provider' do
        expect(provider.admins).to match_array(admins)
      end
    end

    describe '#advocates' do
      it 'only returns advocates in the provider' do
        expect(provider.advocates).to contain_exactly(advocate)
      end
    end
  end

  context 'when validating AGFS supplier number for a chamber' do
    context 'with a blank supplier number' do
      before { chamber.firm_agfs_supplier_number = '' }

      it 'returns no errors' do
        expect(chamber).to be_valid
      end
    end
  end

  context 'when validating AGFS supplier number for a firm' do
    context 'with a blank supplier number' do
      before { agfs_lgfs.firm_agfs_supplier_number = '' }

      it 'returns errors' do
        expect(agfs_lgfs).not_to be_valid
      end
    end

    context 'with a valid supplier number' do
      before { agfs_lgfs.firm_agfs_supplier_number = '2M462' }

      it 'returns no errors' do
        expect(agfs_lgfs).to be_valid
      end
    end

    context 'with an invalid supplier number' do
      before do
        agfs_lgfs.firm_agfs_supplier_number = 'XXX'
        agfs_lgfs.validate
      end

      it 'returns error firm_agfs_supplier_number' do
        expect(agfs_lgfs.errors).to have_key(:firm_agfs_supplier_number)
      end
    end
  end

  context 'when validating LGFS supplier number' do
    it 'validates the supplier numbers sub model for LGFS role' do
      expect_any_instance_of(SupplierNumberSubModelValidator).to receive(:validate_collection_for).with(firm, :lgfs_supplier_numbers)
      firm.valid?
    end

    it 'does not validate the supplier numbers sub model for AGFS role' do
      expect_any_instance_of(SupplierNumberSubModelValidator).not_to receive(:validate_collection_for)
      chamber.valid?
    end

    context 'with blank supplier_number' do
      before do
        allow(firm).to receive(:lgfs_supplier_numbers).and_return([])
        firm.validate
      end

      it { expect(firm.errors.messages_for(:base)).to include('blank_supplier_numbers') }
    end
  end

  describe '#agfs_supplier_numbers' do
    context 'with AGFS provider' do
      let(:provider) { create(:provider, :agfs) }

      before do
        provider.external_users << create(:external_user, :advocate, supplier_number: '888AA')
        provider.external_users << create(:external_user, :advocate, supplier_number: '999BB')
      end

      it 'returns an array of supplier numbers' do
        expect(provider.agfs_supplier_numbers).to match_array %w[888AA 999BB]
      end
    end

    context 'with LGFS provider' do
      let(:provider) { create(:provider, :lgfs) }

      it 'returns an empty array' do
        expect(provider.agfs_supplier_numbers).to be_empty
      end
    end
  end
end
