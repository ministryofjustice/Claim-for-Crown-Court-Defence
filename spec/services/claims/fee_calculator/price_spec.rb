RSpec.describe Claims::FeeCalculator::Price, :fee_calc_vcr do
  subject { described_class.new(price, modifier_name, parent_quantity) }

  # IMPORTANT: use specific case type, offence class, fee types and reporder
  # date in order to reduce and afix VCR cassettes required (that have to match
  # on query values), prevent flickering specs (from random offence classes,
  # rep order dates) and to allow testing actual amounts "calculated".

  let(:price) do
    prices = fee_scheme_prices
    prices.first
  end
  let(:laa_calculator_client) {  LAA::FeeCalculator.client }
  let(:client_fee_scheme) { laa_calculator_client.fee_schemes(1) }
  let(:fee_scheme_prices) { client_fee_scheme.prices(scenario: 5, advocate_type: 'JRALONE', fee_type_code: 'AGFS_APPEAL_CON', unit: 'DAY') }
  let(:modifier_name) { nil }
  let(:parent_quantity) { 1 }

  it { is_expected.to respond_to(:price) }
  it { is_expected.to respond_to(:modifier_name) }
  it { is_expected.to respond_to(:unit) }
  it { is_expected.to respond_to(:per_unit) }
  it { is_expected.to respond_to(:modifier) }
  it { is_expected.to respond_to(:parent_quantity) }

  describe '#price' do
    subject { described_class.new(price, modifier_name, parent_quantity).price }
    it 'returns supplied price object' do
      is_expected.to eql price
    end
  end

  describe '#unit' do
    subject { described_class.new(price, modifier_name, parent_quantity).unit }
    it 'returns a string' do
      is_expected.to be_a String
    end

    it 'returns supplied unit' do
      is_expected.to eql 'DAY'
    end

    context 'when no unit provided' do
      let(:fee_scheme_prices) { client_fee_scheme.prices(scenario: 5, advocate_type: 'JRALONE', fee_type_code: 'AGFS_DISC_FULL') }

      it { is_expected.to eql 'DAY' }
    end

    context 'when the fee is an uplift' do
      let(:fee_scheme_prices) { client_fee_scheme.prices(scenario: 5, advocate_type: 'JRALONE', fee_type_code: 'AGFS_DISC_FULL') }
      let(:modifier_name) { :number_of_defendants }
      let(:parent_quantity) { 1 }

      it { is_expected.to eql 'DEFENDANT' }
    end
  end

  describe '#per_unit' do
    subject { described_class.new(price, modifier_name, parent_quantity).per_unit }

    it 'returns a float' do
      is_expected.to be_a Float
    end

    context 'for a fee_per_unit fee (e.g. appeal against crown court conviction)' do
      it 'returns expected amount' do
        is_expected.to eql 130.0
      end

      context 'with number of cases modifier' do
        let(:modifier_name) { :number_of_cases }
        let(:parent_quantity) { 1 }

        it 'returns amount multiplied by scale factor' do
          is_expected.to eql 26.0
        end
      end

      context 'with number of cases modifier and parent quantity of greater than 1' do
        let(:modifier_name) { :number_of_cases }
        let(:parent_quantity) { 2 }

        it 'returns amount multiplied by scale factor multiplied by parent quantity' do
          is_expected.to eql 52.0
        end
      end

      context 'with number of defendants uplift' do
        let(:modifier_name) { :number_of_defendants }
        let(:parent_quantity) { 1 }

        it 'returns amount multiplied by scale factor' do
          is_expected.to eql 26.0
        end
      end
    end

    context 'for a fixed_fee fee (e.g. elected case not proceeded)' do
      let(:price) do
        client = LAA::FeeCalculator.client
        fee_scheme = client.fee_schemes(1)
        prices = fee_scheme.prices(scenario: 12, advocate_type: 'JRALONE', fee_type_code: 'AGFS_FEE', unit: 'DAY')
        prices.first
      end

      it 'returns expected amount' do
        is_expected.to eql 194.0
      end

      context 'with number of cases modifier' do
        let(:modifier_name) { :number_of_cases }
        let(:parent_quantity) { 1 }

        it 'returns amount multiplied by scale factor' do
          is_expected.to eql 38.80
        end
      end

      context 'with number of cases modifier and parent quantity of greater than 1' do
        let(:modifier_name) { :number_of_cases }
        let(:parent_quantity) { 2 }

        it 'returns amount multiplied by scale factor, ignoring parent quantity' do
          is_expected.to eql 38.8
        end
      end
    end
  end

  describe '#modifier' do
    subject { described_class.new(price, modifier_name, parent_quantity).modifier }

    context 'for prices without modifier specified' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'for prices with invalid modifier specified' do
      let(:modifier_name) { :invalid_modifier_name }
      it 'raises an error' do
        expect { subject }.to raise_error 'Modifier not found'
      end
    end

    context 'for prices with modifier specified' do
      let(:modifier_name) { :number_of_defendants }

      it 'returns OpenStruct object wrapped modifier object' do
        is_expected.to be_an OpenStruct
      end

      it 'returns expected percent_per_unit' do
        is_expected.to have_attributes(percent_per_unit: '20.00')
      end

      it 'returns expected modifier object' do
        expect(subject.modifier_type).to have_attributes(name: 'NUMBER_OF_DEFENDANTS')
      end
    end
  end
end
