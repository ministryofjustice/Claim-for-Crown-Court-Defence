# == Schema Information
#
# Table name: providers
#
#  id              :integer          not null, primary key
#  name            :string
#  supplier_number :string
#  provider_type   :string
#  vat_registered  :boolean
#  uuid            :uuid
#  api_key         :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Provider, type: :model do
  let!(:firm) { create(:provider, :firm) }
  let!(:chamber) { create(:provider, :chamber) }

  it { should have_many(:external_users) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:provider_type) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should delegate_method(:advocates).to(:external_users) }
  it { should delegate_method(:admins).to(:external_users) }

  context 'when firm' do
    subject { firm }

    it { should validate_presence_of(:supplier_number) }
    # it { should validate_uniqueness_of(:supplier_number) }
  end

  context 'when chamber' do
    subject { chamber }

    it { should_not validate_presence_of(:supplier_number) }
    it { should_not validate_uniqueness_of(:supplier_number) }
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
      expect{ chamber.regenerate_api_key! }.to change{ chamber.api_key }.from(old_api_key)
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
end
