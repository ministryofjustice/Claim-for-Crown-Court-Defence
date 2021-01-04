require 'rails_helper'

describe Claims::UpdateClaim do
  after(:all) do
    clean_database
  end

  context 'claim updating' do
    let(:claim) { create :advocate_claim, case_number: 'A20161234' }
    let(:claim_params) { { case_number: 'A20165555' } }

    subject { described_class.new(claim, params: claim_params) }

    it 'defines the action' do
      expect(subject.action).to eq(:edit)
    end

    it 'is not a draft' do
      expect(subject.draft?).to be_falsey
    end

    context 'successful updates' do
      it 'forces validation' do
        allow(subject.claim).to receive(:force_validation=).with(true)
        subject.call
      end

      it 'updates the source when editing an API submitted claim' do
        allow(subject.claim).to receive(:from_api?).and_return(true)
        subject.call
        expect(subject.claim.source).to eq('api_web_edited')
      end

      it 'updates the source when editing a JSON imported claim' do
        allow(subject.claim).to receive(:from_json_import?).and_return(true)
        subject.call
        expect(subject.claim.source).to eq('json_import_web_edited')
      end

      it 'is successful' do
        expect(subject.claim.case_number).to eq('A20161234')
        expect(subject.claim).to receive(:update_claim_document_owners)

        subject.call

        expect(subject.result.success?).to be_truthy
        expect(subject.result.error_code).to be_nil
        expect(subject.claim.case_number).to eq('A20165555')
      end

      context 'when submitting persisted agfs fixed fees marked for destruction' do
        let(:claim) { create :advocate_claim, :with_fixed_fee_case, fixed_fees: fixed_fees }
        let(:claim_params) { { 'form_step' => 'fixed_fees', "fixed_fees_attributes": { "0": { 'id' => fixed_fees.first.id.to_s, 'fee_type_id' => '12', 'quantity' => '', 'rate' => '', 'price_calculated' => 'true', '_destroy' => 'true' } } } }
        let(:fixed_fees) { [build(:fixed_fee, :fxase_fee, rate: 0.50), build(:fixed_fee, :fxsaf_fee, quantity: 1)] }

        before do
          seed_case_types
          seed_fee_types
        end

        it 'deletes the required fees' do
          expect { subject.call }.to change { claim.fixed_fees.count }.from(2).to(1)
        end
      end
    end

    context 'unsuccessful updates' do
      let(:claim_params) { { case_number: '123456789012345678901' } }

      it 'is unsuccessful' do
        expect(subject.claim).not_to receive(:update_claim_document_owners)

        subject.call

        expect(subject.result.success?).to be_falsey
        expect(subject.result.error_code).to eq(:rollback)
      end

      it 'is unsuccessful for an already submitted claim' do
        allow(subject).to receive(:already_submitted?).and_return(true)
        expect(subject.claim).not_to receive(:update_claim_document_owners)

        subject.call

        expect(subject.result.success?).to be_falsey
        expect(subject.result.error_code).to eq(:already_submitted)
      end
    end
  end
end
