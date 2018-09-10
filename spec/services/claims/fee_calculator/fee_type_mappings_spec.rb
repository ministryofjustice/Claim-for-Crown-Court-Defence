RSpec.describe Claims::FeeCalculator::FeeTypeMappings do
  subject(:instance) { described_class.instance }

  before do
    seed_case_types
    described_class.reset
  end

  it { is_expected.to respond_to :all }
  it { is_expected.to respond_to :primary_fee_types }

  let(:fixed_fee_mappings) { CCR::Fee::FixedFeeAdapter::FIXED_FEE_BILL_MAPPINGS.keys }
  let(:misc_fee_mappings) { CCR::Fee::MiscFeeAdapter::MISC_FEE_BILL_MAPPINGS.keys }
  let(:all_fee_mappings) { fixed_fee_mappings + misc_fee_mappings }
  let(:primary_fee_types) { %i[FXACV FXASE FXCBR FXCSE FXCON FXENP] }

  describe '.reset' do
    it 'causes memoized data to be cleared/reset' do
      expect(described_class.instance.primary_fee_types.keys).to include(:FXACV)
      CaseType.find_by(fee_type_code: 'FXACV').delete
      described_class.reset
      expect(described_class.instance.primary_fee_types.keys).to_not include(:FXACV)
    end
  end

  describe '#all' do
    subject { described_class.instance.all }

    let(:fee_mappings) { fixed_fee_mappings + misc_fee_mappings }
    it 'returns all fee type mappings' do
      expect(subject.keys).to match_array(fee_mappings)
    end
  end

  describe '#primary_fee_types' do
    subject { described_class.instance.primary_fee_types }

    it 'returns fee type mappings for fee types that are also case types' do
      expect(subject.keys).to match_array(primary_fee_types)
    end
  end
end
