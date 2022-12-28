require 'rails_helper'
require 'models/fee_scheme_factory/shared_examples'

RSpec.shared_examples 'find LGFS fee schemes' do
  context 'with a rep order before cutoff date' do
    let(:representation_order_date) { rep_order_cutoff_date - 1.day }

    it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 9) }
  end

  context 'with a rep order on cutoff date' do
    let(:representation_order_date) { rep_order_cutoff_date }

    it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
  end

  context 'with a rep order after cutoff date' do
    let(:representation_order_date) { rep_order_cutoff_date + 1.day }

    it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
  end
end

RSpec.describe FeeSchemeFactory::LGFS do
  subject(:factory) { described_class.new(**options) }

  describe '#call' do
    subject { factory.call }

    include_examples 'a fee scheme factory'

    context 'without a main hearing date' do
      let(:options) { { representation_order_date: } }

      include_examples 'find LGFS fee schemes' do
        let(:rep_order_cutoff_date) { Date.parse('30 September 2022') }
      end
    end

    context 'with a main hearing date before 31 October 2022' do
      let(:options) { { representation_order_date:, main_hearing_date: Date.parse('30 October 2022') } }

      include_examples 'find LGFS fee schemes' do
        let(:rep_order_cutoff_date) { Date.parse('30 September 2022') }
      end
    end

    context 'with a main hearing date on 31 October 2022' do
      let(:options) { { representation_order_date:, main_hearing_date: Date.parse('31 October 2022') } }

      include_examples 'find LGFS fee schemes' do
        let(:rep_order_cutoff_date) { Date.parse('17 September 2020') }
      end
    end
  end
end
