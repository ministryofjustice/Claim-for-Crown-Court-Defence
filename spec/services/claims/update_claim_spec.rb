require 'rails_helper'

describe Claims::UpdateClaim do

  after(:all) do
    clean_database
  end

  context 'claim updating' do
    let(:claim) { FactoryGirl.create :advocate_claim, case_number: 'A12345678' }
    let(:claim_params) { { case_number: 'A55555555' } }

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

      it 'is successful' do
        expect(subject.claim.case_number).to eq('A12345678')
        expect(subject.claim).to receive(:update_claim_document_owners)

        subject.call

        expect(subject.result.success?).to be_truthy
        expect(subject.result.error_code).to be_nil
        expect(subject.claim.case_number).to eq('A55555555')
      end
    end

    context 'unsuccessful updates' do
      let(:claim_params) { { case_number: '123' } }

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
