require 'rails_helper'

RSpec.describe Provider, type: :model do
  let!(:firm) { create(:provider, :firm) }
  let!(:chamber) { create(:provider, :chamber) }

  it { should have_many(:external_users) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:provider_type) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

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
end
