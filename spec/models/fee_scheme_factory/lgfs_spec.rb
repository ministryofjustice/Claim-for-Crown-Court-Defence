require 'rails_helper'
require 'models/fee_scheme_factory/shared_examples'

# Shared examples are used to test straightforward test cases, where the
# fee scheme is not affected by the main hearing date. For more complex
# scenarios (ie where the fee scheme falls into the CLAIR contingency period and
# therefore the main hearing date affects the fee scheme), tests are defined in
# the appropriate context below.

# Simple cases where the rep order date falls outside of the
# backdated CLAIR contingency period (17/09/2020 - 29/09/2022).
# Main hearing date has no affect on the calculation of the fee scheme.
RSpec.shared_examples 'find LGFS fee schemes 9 and 10' do
  context 'with a rep order before 17 September 2020' do
    let(:representation_order_date) { Date.parse('16 September 2020') }

    it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 9) }
  end

  context 'with a rep order on 30 September 2022' do
    let(:representation_order_date) { Date.parse('30 September 2022') }

    it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
  end
end

# Simple cases where the rep order date falls after CLAIR. This includes
# fee scheme 11 (27/02/2026) onwards. Tests for new fee schemes can be
# added here.
RSpec.shared_examples 'find LGFS fee scheme 11+' do
  context 'with a rep order on 27 February 2026' do
    let(:representation_order_date) { Date.parse('27 February 2026') }

    before { travel_to(Date.new(2026, 2, 28)) }

    it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 11) }
  end
end

RSpec.describe FeeSchemeFactory::LGFS do
  subject(:factory) { described_class.new(**options) }

  describe '#call' do
    subject { factory.call }

    include_examples 'a fee scheme factory'

    context 'without a main hearing date' do
      let(:options) { { representation_order_date: } }

      include_examples 'find LGFS fee schemes 9 and 10'
      include_examples 'find LGFS fee scheme 11+'

      # rep order is dated between 17/09/2020 and 29/09/2022 but no main hearing
      # date is present and therefore these claims fall into fee scheme 9
      context 'with a rep order on 17 September 2020' do
        let(:representation_order_date) { Date.parse('17 September 2020') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 9) }
      end

      context 'with a rep order before 30 September 2022' do
        let(:representation_order_date) { Date.parse('29 September 2022') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 9) }
      end
    end

    context 'with a main hearing date before 31 October 2022' do
      let(:options) { { representation_order_date:, main_hearing_date: Date.parse('30 October 2022') } }

      include_examples 'find LGFS fee schemes 9 and 10'
      include_examples 'find LGFS fee scheme 11+'

      # rep order is dated between 17/09/2020 and 29/09/2022 but the main hearing
      # date is before 30/09/2022 and therefore the claim fall into fee scheme 9
      context 'with a rep order on 17 September 2020' do
        let(:representation_order_date) { Date.parse('17 September 2020') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 9) }
      end

      context 'with a rep order before 30 September 2022' do
        let(:representation_order_date) { Date.parse('29 September 2022') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 9) }
      end
    end

    context 'with a main hearing date on 31 October 2022' do
      let(:options) { { representation_order_date:, main_hearing_date: Date.parse('31 October 2022') } }

      include_examples 'find LGFS fee schemes 9 and 10'
      include_examples 'find LGFS fee scheme 11+'

      # rep order is dated between 17/09/2020 and 29/09/2022 and the main hearing
      # date on or after 31/09/2022 and therefore the claim fall into fee scheme 10
      context 'with a rep order on 17 September 2020' do
        let(:representation_order_date) { Date.parse('17 September 2020') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
      end

      context 'with a rep order before 30 September 2022' do
        let(:representation_order_date) { Date.parse('29 September 2022') }

        it { is_expected.to eq FeeScheme.find_by(name: 'LGFS', version: 10) }
      end
    end
  end
end
