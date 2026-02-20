require 'rails_helper'
require 'models/fee_scheme_factory/shared_examples'

RSpec.shared_examples 'find AGFS fee schemes 9 to 11' do
  context 'with a rep order before 1 April 2018' do
    let(:representation_order_date) { Date.parse('31 March 2018') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 9) }
  end

  context 'with a rep order on 1 April 2018' do
    let(:representation_order_date) { Date.parse('1 April 2018') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 10) }
  end

  context 'with a rep order before 31 December 2018' do
    let(:representation_order_date) { Date.parse('30 December 2018') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 10) }
  end

  context 'with a rep order on 31 December 2018' do
    let(:representation_order_date) { Date.parse('31 December 2018') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 11) }
  end

  context 'with a rep order before 17 September 2020' do
    let(:representation_order_date) { Date.parse('16 September 2020') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 11) }
  end
end

RSpec.shared_examples 'find AGFS fee schemes 12+' do
  context 'with a rep order on 17 September 2020' do
    let(:representation_order_date) { Date.parse('17 September 2020') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 12) }
  end

  context 'with a rep order before 30 September 2022' do
    let(:representation_order_date) { Date.parse('29 September 2022') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 12) }
  end

  context 'with a rep order on 30 September 2022' do
    let(:representation_order_date) { Date.parse('30 September 2022') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 13) }
  end

  context 'with a rep order before 1 Febraury 2023' do
    let(:representation_order_date) { Date.parse('31 January 2023') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 13) }
  end

  context 'with a rep order on 1 February 2023' do
    let(:representation_order_date) { Date.parse('1 February 2023') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 14) }
  end

  context 'with a rep order before 17 April 2023' do
    let(:representation_order_date) { Date.parse('16 April 2023') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 14) }
  end

  context 'with a rep order on 17 April 2023' do
    let(:representation_order_date) { Date.parse('17 April 2023') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 15) }
  end

  context 'with a rep order on 16 November 2023' do
    let(:representation_order_date) { Date.parse('16 November 2023') }

    it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 16) }
  end
end

RSpec.describe FeeSchemeFactory::AGFS do
  subject(:factory) { described_class.new(**options) }

  describe '#call' do
    subject { factory.call }

    include_examples 'a fee scheme factory'

    context 'without a main hearing date' do
      let(:options) { { representation_order_date: } }

      include_examples 'find AGFS fee schemes 9 to 11'
      include_examples 'find AGFS fee schemes 12+'
    end

    context 'with a main hearing date before 31 October 2022' do
      let(:options) { { representation_order_date:, main_hearing_date: Date.parse('30 October 2022') } }

      include_examples 'find AGFS fee schemes 9 to 11'
      include_examples 'find AGFS fee schemes 12+'
    end

    context 'with a main hearing date on 31 October 2022' do
      let(:options) { { representation_order_date:, main_hearing_date: Date.parse('31 October 2022') } }

      include_examples 'find AGFS fee schemes 9 to 11'

      context 'with a rep order on 17 September 2020' do
        let(:representation_order_date) { Date.parse('17 September 2020') }

        it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 13) }
      end
    end

    context 'with a main hearing date on 1 February 2023' do
      let(:options) { { representation_order_date:, main_hearing_date: Date.parse('1 February 2023') } }

      include_examples 'find AGFS fee schemes 9 to 11'

      context 'with a rep order before 1 February 2023' do
        let(:representation_order_date) { Date.parse('31 January 2023') }

        it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 13) }
      end

      context 'with a rep order on 1 February 2023' do
        let(:representation_order_date) { Date.parse('1 February 2023') }

        it { is_expected.to eq FeeScheme.find_by(name: 'AGFS', version: 14) }
      end
    end
  end
end
