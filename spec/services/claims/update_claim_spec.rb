require 'rails_helper'

describe Claims::UpdateClaim do
  after(:all) do
    clean_database
  end

  context 'claim updating' do
    let(:claim) { create(:advocate_claim, case_number: 'A20161234') }
    let(:claim_params) { { case_number: 'A20165555' } }

    subject(:update_claim) { described_class.new(claim, params: claim_params) }

    it 'defines the action' do
      expect(update_claim.action).to eq(:edit)
    end

    it 'is not a draft' do
      expect(update_claim.draft?).to be_falsey
    end

    context 'successful updates' do
      it 'forces validation' do
        allow(update_claim.claim).to receive(:force_validation=).with(true)
        expect { update_claim.call }.not_to raise_error
      end

      it 'updates the source when editing an API submitted claim' do
        allow(update_claim.claim).to receive(:from_api?).and_return(true)
        update_claim.call
        expect(update_claim.claim.source).to eq('api_web_edited')
      end

      it 'is successful' do
        expect(update_claim.claim.case_number).to eq('A20161234')
        expect(update_claim.claim).to receive(:update_claim_document_owners)

        update_claim.call

        expect(update_claim.result.success?).to be_truthy
        expect(update_claim.result.error_code).to be_nil
        expect(update_claim.claim.case_number).to eq('A20165555')
      end

      context 'when submitting persisted agfs fixed fees marked for destruction' do
        let(:claim) { create(:advocate_claim, :with_fixed_fee_case, fixed_fees:) }
        let(:claim_params) { { 'form_step' => 'fixed_fees', fixed_fees_attributes: { '0': { 'id' => fixed_fees.first.id.to_s, 'fee_type_id' => '12', 'quantity' => '', 'rate' => '', 'price_calculated' => 'true', '_destroy' => 'true' } } } }
        let(:fixed_fees) { [build(:fixed_fee, :fxase_fee, rate: 0.50), build(:fixed_fee, :fxsaf_fee, quantity: 1)] }

        before do
          seed_case_types
          seed_fee_types
        end

        it 'deletes the required fees' do
          expect { update_claim.call }.to change { claim.fixed_fees.count }.from(2).to(1)
        end
      end
    end

    context 'unsuccessful updates' do
      let(:claim_params) { { case_number: '123456789012345678901' } }

      it 'is unsuccessful' do
        expect(update_claim.claim).not_to receive(:update_claim_document_owners)

        update_claim.call

        expect(update_claim.result.success?).to be_falsey
        expect(update_claim.result.error_code).to eq(:rollback)
      end

      it 'is unsuccessful for an already submitted claim' do
        allow(update_claim).to receive(:already_submitted?).and_return(true)
        expect(update_claim.claim).not_to receive(:update_claim_document_owners)

        update_claim.call

        expect(update_claim.result.success?).to be_falsey
        expect(update_claim.result.error_code).to eq(:already_submitted)
      end
    end
  end
end
