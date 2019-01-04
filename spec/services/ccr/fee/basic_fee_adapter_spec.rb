require 'rails_helper'
RSpec.shared_examples_for 'a basic fee adapter' do
  describe '#mappings' do
    subject { instance.mappings }

    %i[BABAF BADAF BADAH BADAJ BANOC BANDR BANPW BAPPE].each do |basic_fee_unique_code|
      it "includes mappings for basic fee #{basic_fee_unique_code} to a CCR Advocate Fee bill type - AGFS_FEE" do
        is_expected.to include(basic_fee_unique_code => { bill_type: 'AGFS_FEE', bill_subtype: 'AGFS_FEE'})
      end
    end
  end

  describe '#bill_type' do
    subject { instance.bill_type }

    it 'returns CCR Advocate Fee bill type' do
      is_expected.to eql 'AGFS_FEE'
    end
  end

  describe '#bill_subtype' do
    subject { instance.bill_subtype }

    it 'returns CCR Advocate Fee bill subtype' do
      is_expected.to eql 'AGFS_FEE'
    end
  end
end

RSpec.describe CCR::Fee::BasicFeeAdapter, type: :adapter do
  context 'when instantiated without a claim object' do
    subject(:instance) { described_class.new }

    it_behaves_like 'a simple bill adapter', bill_type: 'AGFS_FEE', bill_subtype: 'AGFS_FEE' do
      let(:fee) { instance_double(Fee::BasicFee) }
    end

    it_behaves_like 'a basic fee adapter' do
      let(:instance) { described_class.new }
    end

    describe '#claimed?' do
      subject { instance.claimed? }

      it 'raises error' do
        expect { subject }.to raise_error ArgumentError, 'Instantiate with claim object to use this method'
      end
    end
  end

  context 'when instantiated with claim object' do
    subject(:instance) { described_class.new(claim) }
    let(:claim) { instance_double('claim') }

    it_behaves_like 'a simple bill adapter', bill_type: 'AGFS_FEE', bill_subtype: 'AGFS_FEE' do
      let(:fee) { instance_double(Fee::BasicFee) }
    end

    it_behaves_like 'a basic fee adapter' do
      let(:instance) { described_class.new(claim) }
    end

    describe '#claimed?' do
      subject { instance.claimed? }

      let(:basic_fee_type) { instance_double(::Fee::BasicFeeType, unique_code: 'BABAF') }
      let(:basic_fees) { [basic_fee] }
      let(:basic_fee) do
        instance_double(
          ::Fee::BasicFee,
          fee_type: basic_fee_type,
          quantity: 0,
          rate: 0,
          amount: 0,
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

      it 'returns false when the basic fee is not part of the CCR advocate fee' do
        allow(basic_fee_type).to receive(:unique_code).and_return 'BAPCM'
        is_expected.to be false
      end
    end
  end
end
