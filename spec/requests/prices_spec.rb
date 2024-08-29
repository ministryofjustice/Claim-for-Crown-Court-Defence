require 'rails_helper'

RSpec.describe 'calcuate prices' do
  describe 'POST /external_users/claims/claim_id/fees/calculate_price.json' do
    subject(:calculate_price) { post external_users_claim_fees_calculate_price_url(claim.id, format: :json), params: }

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'with LGFS Special Preparation fee' do
      let(:external_user) { create(:external_user) }
      let(:user) { external_user.user }
      let(:fee_type) { create(:misc_fee_type, :mispf) }
      let(:fee) { create(:misc_fee, fee_type:, claim:, quantity: 1) }
      let(:mock_client) { instance_double(LAA::FeeCalculator::Client) }
      let(:mock_fee_scheme) { instance_double(LAA::FeeCalculator::FeeScheme) }
      let(:params) do
        { format: :json,
          claim_id: claim.id,
          price_type: 'UnitPrice',
          fee_type_id: fee.fee_type.id,
          fees: {
            '0': { fee_type_id: fee.fee_type.id, quantity: fee.quantity }
          } }
      end

      before do
        allow(LAA::FeeCalculator).to receive(:client).and_return(mock_client)
        allow(mock_client).to receive(:fee_schemes).and_return(mock_fee_scheme)

        # Rubocop doesn't like this but without it, execution fails as
        # CalculatePrice needs to call its own Scenario method
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Claims::FeeCalculator::CalculatePrice)
          .to receive(:scenario)
          .and_return(Struct.new(:id).new('1'))
        # rubocop:enable RSpec/AnyInstance
      end

      describe 'with london_rates_apply true' do
        let(:claim) { create(:litigator_claim, london_rates_apply: true) }

        before do
          allow(mock_fee_scheme).to receive(:prices).with(london_rates_apply: true).and_return({ fee_per_unit: 100 })
          sign_in user
          calculate_price
        end

        it 'submits a request with the expected parameters' do
          expect(mock_fee_scheme).to have_received(:prices).with(hash_including(london_rates_apply: true))
        end
      end

      describe 'with london_rates_apply false' do
        let(:claim) { create(:litigator_claim, london_rates_apply: false) }

        before do
          allow(mock_fee_scheme).to receive(:prices).with(london_rates_apply: false).and_return({ fee_per_unit: 50 })
          sign_in user
          calculate_price
        end

        it 'submits a request with the expected parameters' do
          expect(mock_fee_scheme).to have_received(:prices).with(hash_including(london_rates_apply: false))
        end
      end

      describe 'with london_rates_apply not specified' do
        let(:claim) { create(:litigator_claim) }

        before do
          allow(mock_fee_scheme).to receive(:prices).and_return({})
          sign_in user
          calculate_price
        end

        it 'submits a request with the expected parameters' do
          expect(mock_fee_scheme).to have_received(:prices).with(hash_not_including(:london_rates_apply))
        end
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
