RSpec.shared_examples_for 'a mapping fee adapter' do
  describe '#call' do
    it { is_expected.to be_instance_of described_class }
    it { is_expected.to respond_to :bill_type }
    it { is_expected.to respond_to :bill_subtype }
    it { is_expected.to respond_to :object }
    it { is_expected.to respond_to :mappings }
    it { is_expected.to respond_to :exclusions? }
  end

  describe '#mappings' do
    subject { described_class.new.mappings }

    it { is_expected.to be_a Hash }

    it 'each key\'s value is a Hash' do
      expect(subject.values.first).to be_a Hash
    end

    it 'each key\'s value includes bill type and subtype details' do
      expect(subject.values.first.keys).to include(:bill_type, :bill_subtype)
    end
  end
end

RSpec.shared_examples_for 'a simple bill adapter' do |options|
  subject { described_class.new(instance_double('fee')) }

  it { is_expected.to respond_to(:bill_type) }
  it { is_expected.to respond_to(:bill_subtype) }

  it 'should respond to .acts_as_simple_bill' do
    expect(described_class).to respond_to :acts_as_simple_bill
  end

  describe '#bill_type' do
    subject { described_class.new(fee).bill_type }
    it "returns expected bill type - #{options[:bill_type]}" do
      is_expected.to eql options[:bill_type]
    end
  end

  describe '#bill_subtype' do
    subject { described_class.new(fee).bill_subtype }
    it "returns expected bill type - #{options[:bill_subtype]}" do
      is_expected.to eql options[:bill_subtype]
    end
  end
end

RSpec.shared_examples 'a bill types delegator' do |adapter_klass|
  let(:adapter) { instance_double(adapter_klass) }

  it "delegates bill types to #{adapter_klass} " do
    expect(adapter_klass).to receive(:new).with(bill).and_return(adapter)
    expect(adapter).to receive(:bill_type)
    expect(adapter).to receive(:bill_subtype)
    subject
  end
end

RSpec.shared_examples_for 'a basic fee adapter' do |options|
  describe '#mappings' do
    subject { described_class.new.mappings }

    %i[BABAF BADAF BADAH BADAJ BANOC BANDR BANPW BAPPE].each do |basic_fee_unique_code|
      it "includes mappings for basic fee #{basic_fee_unique_code} to a CCR Advocate Fee bill - #{options[:bill_type]}/#{options[:bill_subtype]}" do
        is_expected.to include(basic_fee_unique_code => { bill_type: options[:bill_type], bill_subtype: options[:bill_subtype] })
      end
    end
  end

  describe '#fee_types' do
    subject(:fee_types) { described_class.new.fee_types }

    it 'returns CCR adaptable basic fee type codes' do
      is_expected.to match_array %w[BABAF BADAF BADAH BADAJ BADAT BANOC BANDR BANPW BAPPE]
    end
  end

  describe 'filtered_fees' do
    subject(:filtered_fees) { described_class.new(claim).filtered_fees }

    before do
      claim.fees << build(:basic_fee, :baf_fee, claim: claim) unless claim.fees.map { |f| f.fee_type.unique_code }.include? 'BABAF'
      claim.fees << build(:basic_fee, :daf_fee, claim: claim)
      claim.fees << build(:basic_fee, :daj_fee, claim: claim)
      claim.fees << build(:basic_fee, :dah_fee, claim: claim)
      claim.fees << build(:basic_fee, :dat_fee, claim: claim)
      claim.fees << build(:basic_fee, :noc_fee, claim: claim)
      claim.fees << build(:basic_fee, :ndr_fee, claim: claim)
      claim.fees << build(:basic_fee, :npw_fee, claim: claim)
      claim.fees << build(:basic_fee, :ppe_fee, claim: claim)
      claim.fees << build(:basic_fee, :cav_fee, claim: claim) # not adaptable
      claim.fees << build(:basic_fee, :saf_fee, claim: claim) # not adaptable
      claim.fees << build(:basic_fee, :pcm_fee, claim: claim) # not adaptable
    end

    it 'returns array of basic fee objects' do
      is_expected.to all(be_a(Fee::BasicFee))
    end

    it 'returns only CCR adaptable basic fees' do
      expect(filtered_fees.map { |f| f.fee_type.unique_code }).to match_array %w[BABAF BADAF BADAJ BADAH BADAT BANOC BANDR BANPW BAPPE]
    end
  end

  describe '#claimed?' do
    subject(:claimed?) { instance.claimed? }

    context 'when instantiated without a claim object' do
      let(:instance) { described_class.new }

      it 'raises error' do
        expect { claimed? }.to raise_error ArgumentError, 'Instantiate with claim object to use this method'
      end
    end

    context 'when instantiated with claim object' do
      let(:instance) { described_class.new(claim) }
      let(:claim) { instance_double('claim') }

      let(:basic_fee_type) { instance_double(::Fee::BasicFeeType, unique_code: 'BABAF') }
      let(:basic_fees) { [basic_fee] }
      let(:basic_fee) do
        instance_double(
          ::Fee::BasicFee,
          fee_type: basic_fee_type,
          quantity: 0,
          rate: 0,
          amount: 0
          )
      end

      before do
        expect(claim).to receive(:fees).at_least(:once).and_return basic_fees
      end

      it 'returns true when the basic fee has a positive qauntity' do
        allow(basic_fee).to receive_messages(quantity: 1)
        is_expected.to be true
      end

      it 'returns true when the basic fee has a positive amount' do
        allow(basic_fee).to receive_messages(amount: 1.0)
        is_expected.to be true
      end

      it 'returns true when the basic fee has a positive rate' do
        allow(basic_fee).to receive_messages(rate: 1.0)
        is_expected.to be true
      end

      it 'returns false when the basic fee has 0 values for quantity, rate and amount'do
        allow(basic_fee).to receive_messages(quantity: 0, rate: 0, amount: 0)
        is_expected.to be false
      end

      it 'returns false when the basic fee has nil values for quantity, rate and amount'do
        allow(basic_fee).to receive_messages(quantity: nil, rate: nil, amount: nil)
        is_expected.to be false
      end

      context 'with filtered out fees' do
        %w[BASAF BAPCM BACAV].each do |fee_type_unique_code|
          it "returns false when basic fee is of type #{fee_type_unique_code}" do
            allow(basic_fee_type).to receive(:unique_code).and_return fee_type_unique_code
            allow(basic_fee).to receive_messages(amount: 1)
            is_expected.to be false
          end
        end
      end
    end
  end
end
