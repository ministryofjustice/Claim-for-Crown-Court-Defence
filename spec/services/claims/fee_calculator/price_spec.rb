RSpec.describe Claims::FeeCalculator::Price, :fee_calc_vcr do
  subject { described_class.new(price, unit_modifiers, parent_quantity) }

  MockModifier = Struct.new(:name, :limit_from, keyword_init: true)

  # IMPORTANT: use specific case type, offence class, fee types and reporder
  # date in order to reduce and afix VCR cassettes required (that have to match
  # on query values), prevent flickering specs (from random offence classes,
  # rep order dates) and to allow testing actual amounts "calculated".

  let(:price) do
    prices = fee_scheme_prices
    prices.first
  end

  let(:laa_calculator_client) { LAA::FeeCalculator.client }
  let(:client_fee_scheme) { laa_calculator_client.fee_schemes(1) }
  let(:fee_scheme_prices) { client_fee_scheme.prices(scenario: 5, advocate_type: 'JRALONE', fee_type_code: 'AGFS_APPEAL_CON', unit: 'DAY') }
  let(:unit_modifiers) { [] }
  let(:parent_quantity) { 1 }

  it { is_expected.to respond_to(:price) }
  it { is_expected.to respond_to(:parent_quantity) }
  it { is_expected.to respond_to(:per_unit) }
  it { is_expected.to respond_to(:unit) }
  it { is_expected.to respond_to(:modifiers) }

  describe '#price' do
    subject { described_class.new(price, unit_modifiers, parent_quantity).price }

    it 'returns supplied price object' do
      is_expected.to eql price
    end
  end

  describe '#unit' do
    subject { described_class.new(price, unit_modifiers, parent_quantity).unit }

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
      let(:unit_modifiers) { [MockModifier.new(name: :number_of_defendants, limit_from: 2)] }
      let(:parent_quantity) { 1 }

      it { is_expected.to eql 'DEFENDANT' }
    end
  end

  describe '#per_unit' do
    subject { described_class.new(price, unit_modifiers, parent_quantity).per_unit }

    it 'returns a float' do
      is_expected.to be_a Float
    end

    context 'for a fee_per_unit fee (e.g. appeal against crown court conviction)' do
      it 'returns expected amount' do
        is_expected.to eq 130.0
      end

      context 'with number of cases modifier' do
        let(:unit_modifiers) { [MockModifier.new(name: :number_of_cases, limit_from: 2)] }
        let(:parent_quantity) { 1 }

        it 'returns amount multiplied by scale factor' do
          is_expected.to eq 26.0
        end
      end

      context 'with number of cases modifier and parent quantity of greater than 1' do
        let(:unit_modifiers) { [MockModifier.new(name: :number_of_cases, limit_from: 2)] }
        let(:parent_quantity) { 2 }

        it 'returns amount multiplied by scale factor multiplied by parent quantity' do
          is_expected.to eq 52.0
        end
      end

      context 'with number of defendants modifier' do
        let(:unit_modifiers) { [MockModifier.new(name: :number_of_defendants, limit_from: 2)] }
        let(:parent_quantity) { 1 }

        it 'returns amount multiplied by scale factor' do
          is_expected.to eq 26.0
        end
      end

      context 'with a retrial interval' do
        let(:fee_scheme_prices) { client_fee_scheme.prices(scenario: 11, advocate_type: 'JRALONE', offence_class: 'A', limit_from: 3, limit_to: 40, fee_type_code: 'AGFS_FEE', unit: 'DAY') }
        let(:unit_modifiers) { [MockModifier.new(name: :retrial_interval, limit_from: 0)] }

        context 'within 1 calendar month limit' do
          let(:unit_modifiers) { [MockModifier.new(name: :retrial_interval, limit_from: 0)] }

          it 'returns amount multiplied by inverse scale factor (-30%)' do
            is_expected.to eq 371.00
          end
        end

        context 'over 1 calendar month limit' do
          let(:unit_modifiers) { [MockModifier.new(name: :retrial_interval, limit_from: 1)] }

          it 'returns amount multiplied by inverse scale factor (-20%)' do
            is_expected.to eq 424.00
          end
        end
      end

      # NOTE: this situation represents a possible bug in the fee calc API
      # whereby a retrial interval modifier is not available on a a daily attendance
      # 41 to 50 (or 51+)
      context 'with a retrial interval on price that does not have such a modifier' do
        let(:fee_scheme_prices) { client_fee_scheme.prices(scenario: 11, advocate_type: 'JRALONE', offence_class: 'A', limit_from: 41, limit_to: 50, fee_type_code: 'AGFS_FEE', unit: 'DAY') }
        let(:unit_modifiers) { [MockModifier.new(name: :retrial_interval, limit_from: 0)] }

        context 'within 1 calendar month limit' do
          let(:unit_modifiers) { [MockModifier.new(name: :retrial_interval, limit_from: 0)] }

          it 'returns full amount' do
            is_expected.to eq 266.00
          end
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
        is_expected.to eq 194.0
      end

      context 'with number of cases modifier' do
        let(:unit_modifiers) { [MockModifier.new(name: :number_of_cases, limit_from: 2)] }
        let(:parent_quantity) { 1 }

        it 'returns amount multiplied by scale factor' do
          is_expected.to eq 38.80
        end
      end

      context 'with number of cases modifier and parent quantity of greater than 1' do
        let(:unit_modifiers) { [MockModifier.new(name: :number_of_cases, limit_from: 2)] }
        let(:parent_quantity) { 2 }

        it 'returns amount multiplied by scale factor, ignoring parent quantity' do
          is_expected.to eq 38.8
        end
      end
    end

    context 'for a basic fee' do
      let(:fee_scheme_prices) { client_fee_scheme.prices(scenario: 11, advocate_type: 'JRALONE', offence_class: 'A', limit_from: 1, limit_to: 2, fee_type_code: 'AGFS_FEE', unit: 'DAY') }

      context 'with no modifiers' do
        let(:unit_modifiers) { [] }

        it 'returns unmodified amount' do
          is_expected.to eq 1632.00
        end
      end

      context 'with retrial_interval modifier' do
        let(:unit_modifiers) { [MockModifier.new(name: :retrial_interval, limit_from: 0)] }

        it 'returns amount multiplied by scale factor (-30%)' do
          is_expected.to eq 1142.40
        end
      end

      context 'with retrial_interval and number_of_defendants modifier' do
        let(:unit_modifiers) do
          [
            MockModifier.new(name: :retrial_interval, limit_from: 0),
            MockModifier.new(name: :number_of_defendants, limit_from: 2)
          ]
        end

        it 'returns amount multiplied by inverse scale factor (-30%) and scale factor (20%)' do
          is_expected.to eq 228.48
        end
      end

      context 'with retrial_interval and number_of_cases modifier' do
        let(:unit_modifiers) do
          [
            MockModifier.new(name: :retrial_interval, limit_from: 0),
            MockModifier.new(name: :number_of_cases, limit_from: 2)
          ]
        end

        it 'returns amount multiplied by inverse scale factor (-30%) and scale factor (20%)' do
          is_expected.to eq 228.48
        end
      end
    end
  end

  describe '#modifiers' do
    subject(:modifiers) { described_class.new(price, unit_modifiers, parent_quantity).modifiers }

    context 'for prices without modifiers specified' do
      it { is_expected.to be_empty }
    end

    context 'for prices with invalid modifiers specified' do
      let(:unit_modifiers) { [MockModifier.new(name: :invalid_modifier_name, limit_from: 2)] }

      it { is_expected.to be_empty }
    end

    context 'for prices with modifiers specified' do
      context 'number of defendants' do
        let(:unit_modifiers) { [MockModifier.new(name: :number_of_defendants, limit_from: 2)] }

        it 'returns Array of decorated modifier objects' do
          is_expected.to match_array(an_instance_of(Claims::FeeCalculator::ModifierDecorator))
        end

        context 'modifier' do
          subject(:modifier) { modifiers.first }

          it 'returns expected percent_per_unit' do
            is_expected.to have_attributes(percent_per_unit: '20.00')
          end

          it 'returns expected modifier object' do
            expect(modifier.modifier_type).to have_attributes(name: 'NUMBER_OF_DEFENDANTS')
          end
        end
      end

      context 'retrial interval' do
        let(:fee_scheme_prices) { client_fee_scheme.prices(scenario: 11, advocate_type: 'JRALONE', offence_class: 'A', fee_type_code: 'AGFS_FEE', unit: 'DAY') }
        let(:unit_modifiers) { [MockModifier.new(name: :retrial_interval, limit_from: 0)] }

        it 'returns decorated modifier object' do
          is_expected.to match_array(an_instance_of(Claims::FeeCalculator::ModifierDecorator))
        end

        context 'modifier' do
          subject(:modifier) { modifiers.first }

          context 'within 1 calender month (limit_from 0)' do
            let(:unit_modifiers) { [MockModifier.new(name: :retrial_interval, limit_from: 0)] }

            it 'returns expected fixed_percent' do
              is_expected.to have_attributes(fixed_percent: '-30.00')
            end
          end

          context 'over 1 calender month limit_from 1' do
            let(:unit_modifiers) { [MockModifier.new(name: :retrial_interval, limit_from: 1)] }

            it 'returns expected fixed_percent' do
              is_expected.to have_attributes(fixed_percent: '-20.00')
            end
          end

          it 'returns expected modifier object' do
            expect(modifier.modifier_type).to have_attributes(name: 'RETRIAL_INTERVAL')
          end
        end
      end
    end

    context 'for prices with two or more modifiers specified' do
      context 'retrial interval and defendant uplift' do
        let(:fee_scheme_prices) { client_fee_scheme.prices(scenario: 11, advocate_type: 'JRALONE', offence_class: 'A', fee_type_code: 'AGFS_FEE', unit: 'DAY') }
        let(:unit_modifiers) do
          [
            MockModifier.new(name: :retrial_interval, limit_from: 0),
            MockModifier.new(name: :number_of_defendants, limit_from: 2),
            MockModifier.new(name: :number_of_cases, limit_from: 2),
            MockModifier.new(name: :number_of_cases, limit_from: 101),
            MockModifier.new(name: :not_a_modifier, limit_from: 2),
            MockModifier.new(name: :pages_of_prosecution_evidence, limit_from: 0)
          ]
        end

        it { is_expected.to be_an Array }

        it { is_expected.to all(be_instance_of(Claims::FeeCalculator::ModifierDecorator)) }

        it 'returns valid matching modifier objects that exist on the price object' do
          expect(modifiers.map { |modifier| modifier.modifier_type.name }).to match_array(%w[RETRIAL_INTERVAL NUMBER_OF_DEFENDANTS NUMBER_OF_CASES])
        end

        it 'does not return valid modifier objects that do NOT exist on the price object' do
          expect(modifiers.map { |modifier| modifier.modifier_type.name }).to_not include('PAGES_OF_PROSECUTING_EVIDENCE')
        end
      end
    end
  end
end
