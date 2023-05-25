require 'rails_helper'

describe Claims::CreateDraft do
  after(:all) do
    clean_database
  end

  context 'draft claim creation' do
    # NOTE: a form_step needs to be supplied otherwise the service
    # will validate all the steps for the claim
    let(:claim) { build(:advocate_claim, form_step: :case_details) }
    let(:validate) { true }

    subject(:create_draft) { described_class.new(claim, validate:) }

    it 'defines the action' do
      expect(create_draft.action).to eq(:new)
    end

    context 'successful draft creations' do
      context 'validation enabled' do
        let(:validate) { true }

        it 'forces validation if indicated' do
          allow(create_draft.claim).to receive(:force_validation=).with(true)
          expect { create_draft.call }.not_to raise_error
        end
      end

      context 'validation not enabled' do
        let(:validate) { false }

        it 'forces validation if indicated' do
          allow(create_draft.claim).to receive(:force_validation=).with(false)
          expect { create_draft.call }.not_to raise_error
        end
      end

      it 'is successful' do
        expect(create_draft.claim.persisted?).to be_falsey

        create_draft.call

        expect(create_draft.result.success?).to be_truthy
        expect(create_draft.result.error_code).to be_nil
        expect(create_draft.claim.persisted?).to be_truthy
      end
    end

    context 'unsuccessful draft creations' do
      it 'is unsuccessful' do
        claim.case_number = nil

        expect(create_draft.claim.persisted?).to be_falsey

        create_draft.call

        expect(create_draft.result.success?).to be_falsey
        expect(create_draft.result.error_code).to eq(:rollback)
        expect(create_draft.claim.persisted?).to be_falsey
      end

      it 'is unsuccessful for an already submitted claim' do
        expect(create_draft.claim.persisted?).to be_falsey
        allow(create_draft).to receive(:already_saved?).and_return(true)

        create_draft.call

        expect(create_draft.result.success?).to be_falsey
        expect(create_draft.result.error_code).to eq(:already_saved)
        expect(create_draft.claim.persisted?).to be_falsey
      end
    end
  end
end
