require 'rails_helper'

RSpec.describe FeeSchemeFactory::LGFS do
  subject(:factory) { described_class.new(representation_order_date:, main_hearing_date:) }

  describe '#call' do
    subject { factory.call }

    before { seed_fee_schemes }

    context 'without a main hearing date' do
      let(:main_hearing_date) { nil }

      context 'with a rep order before 30 September 2022' do
        let(:representation_order_date) { Date.parse('29 September 2022') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 9) }
      end

      context 'with a rep order on 30 September 2022' do
        let(:representation_order_date) { Date.parse('30 September 2022') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
      end

      context 'with a rep order after 30 September 2022' do
        let(:representation_order_date) { Date.parse('1 October 2022') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
      end
    end

    context 'with a main hearing date before 31 October 2022' do
      let(:main_hearing_date) { Date.parse('30 October 2022') }

      context 'with a rep order before 30 September 2022' do
        let(:representation_order_date) { Date.parse('29 September 2022') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 9) }
      end

      context 'with a rep order on 30 September 2022' do
        let(:representation_order_date) { Date.parse('30 September 2022') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
      end

      context 'with a rep order after 30 September 2022' do
        let(:representation_order_date) { Date.parse('1 October 2022') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
      end
    end

    context 'with a main hearing date on 31 October 2022' do
      let(:main_hearing_date) { Date.parse('31 October 2022') }

      context 'with a rep order before 17 September 2020' do
        let(:representation_order_date) { Date.parse('16 September 2020') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 9) }
      end

      context 'with a rep order on 17 September 2020' do
        let(:representation_order_date) { Date.parse('17 September 2020') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
      end

      context 'with a rep order after 17 September 2020' do
        let(:representation_order_date) { Date.parse('18 October 2020') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
      end
    end
  end
end
