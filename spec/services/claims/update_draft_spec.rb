require 'rails_helper'

RSpec.describe Claims::UpdateDraft do
  after(:all) do
    clean_database
  end

  context 'draft claim updates' do
    let(:original_case_number) { 'A20161234' }
    let(:claim) { create(:advocate_claim, case_number: original_case_number) }
    let(:claim_params) { { case_number: 'A20165555' } }
    let(:validate) { true }

    subject(:update_draft) { described_class.new(claim, params: claim_params, validate:) }

    it 'defines the action' do
      expect(update_draft.action).to eq(:edit)
    end

    it 'is a draft' do
      expect(update_draft.draft?).to be_truthy
    end

    context 'successful draft updates' do
      context 'validation enabled' do
        let(:validate) { true }

        it 'forces validation if indicated' do
          allow(update_draft.claim).to receive(:force_validation=).with(true)
          expect { update_draft.call }.not_to raise_error
        end
      end

      context 'validation not enabled' do
        let(:validate) { false }

        it 'forces validation if indicated' do
          allow(update_draft.claim).to receive(:force_validation=).with(false)
          expect { update_draft.call }.not_to raise_error
        end
      end

      it 'updates the source when editing an API submitted claim' do
        allow(update_draft.claim).to receive(:from_api?).and_return(true)
        update_draft.call
        expect(update_draft.claim.source).to eq('api_web_edited')
      end

      it 'is successful' do
        expect(update_draft.claim.case_number).to eq('A20161234')

        update_draft.call

        expect(update_draft.result.success?).to be_truthy
        expect(update_draft.result.error_code).to be_nil
        expect(update_draft.claim.case_number).to eq('A20165555')
      end
    end

    context 'unsuccessful draft updates' do
      let(:claim_params) { { case_number: '123/' } }

      it 'is unsuccessful' do
        update_draft.call

        expect(update_draft.result.success?).to be_falsey
        expect(update_draft.result.error_code).to eq(:rollback)
      end
    end

    context 'updating a previously submitted claim that was saved as a draft with an invalid associated record' do
      let(:fee_type) { create(:interim_fee_type, :warrant) }
      let(:claim) { create(:interim_claim, case_number: 'A20161234') }
      let(:draft_claim_params) {
        {
          'form_step' => 'fees',
          'interim_fee_attributes' => {
            'fee_type_id' => fee_type.id,
            'quantity' => '',
            'warrant_issued_date(3i)' => '',
            'warrant_issued_date(2i)' => '',
            'warrant_issued_date(1i)' => '',
            'warrant_executed_date(3i)' => '',
            'warrant_executed_date(2i)' => '',
            'warrant_executed_date(1i)' => '',
            'amount' => ''
          }
        }
      }

      before do
        described_class.new(claim, params: draft_claim_params, validate: false).call
      end

      context 'when current form step does not require the invalid record to be validated' do
        let(:new_case_number) { 'A20165555' }
        let(:claim_params) {
          {
            'form_step' => 'case_details',
            'case_number' => new_case_number
          }
        }

        it 'successfully updates the claim with the submitted params' do
          result = update_draft.call

          expect(result).to be_success
          expect(claim.reload.case_number).to eq(new_case_number)
        end
      end

      context 'when current form step requires the invalid record to be validated' do
        let(:claim_params) {
          {
            'form_step' => 'interim_fees',
            'case_number' => 'A20165555'
          }
        }

        it 'does not update the claim' do
          result = update_draft.call

          expect(result).not_to be_success
          expect(result.error_code).to eq(:rollback)
          expect(claim.reload.case_number).to eq(original_case_number)
        end
      end
    end
  end
end
