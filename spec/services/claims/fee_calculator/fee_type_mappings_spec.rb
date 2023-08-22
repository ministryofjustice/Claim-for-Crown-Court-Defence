RSpec.describe Claims::FeeCalculator::FeeTypeMappings do
  subject(:instance) { described_class.instance }

  before do
    seed_case_types
    described_class.reset
  end

  after do
    # important to not impact other tests
    described_class.reset
  end

  let(:primary_fee_types) { %i[FXACV FXASE FXCBR FXCSE FXCON FXENP BABAF] }
  let(:all_fee_mappings) { basic_fee_mappings + fixed_fee_mappings + misc_fee_mappings }
  let(:misc_fee_mappings) { CCR::Fee::MiscFeeAdapter.new(exclusions: false).mappings.keys }
  let(:fixed_fee_mappings) { CCR::Fee::FixedFeeAdapter.new.mappings.keys }
  let(:basic_fee_mappings) { CCR::Fee::BasicFeeAdapter.new.mappings.keys }

  it { is_expected.to respond_to :all }
  it { is_expected.to respond_to :primary_fee_types }

  describe '.reset' do
    it 'causes memoized data to be cleared/reset' do
      expect(described_class.instance.primary_fee_types.keys).to include(:FXACV)
      CaseType.find_by(fee_type_code: 'FXACV').delete
      described_class.reset
      expect(described_class.instance.primary_fee_types.keys).to_not include(:FXACV)
    end

    it 'sets instance vars to nil' do
      expect(described_class.instance).to receive(:instance_variable_set).with(:@all, nil).at_least(:once)
      expect(described_class.instance).to receive(:instance_variable_set).with(:@primary_fee_types, nil).at_least(:once)
      expect(described_class.instance).to receive(:instance_variable_set).with(:@primary_fee_type_codes, nil).at_least(:once)
      described_class.reset
    end
  end

  describe '#all' do
    subject { described_class.instance.all }

    let(:exclusions) { %i[BACAV MIPHC MIUMU MIUMO] }

    it 'returns all fee type mappings' do
      expect(subject.keys).to match_array(all_fee_mappings)
    end

    it 'returns fee types excluded by default' do
      expect(subject.keys).to include(*exclusions)
    end
  end

  describe '#primary_fee_types' do
    subject { described_class.instance.primary_fee_types }

    it 'returns fee type mappings for fee types that are also case types' do
      expect(subject.keys).to match_array(primary_fee_types)
    end
  end
end
