require 'rails_helper'

describe Claims::CreateClaim do
  after(:all) do
    clean_database
  end

  let(:claim) { FactoryGirl.build :advocate_claim, uuid: SecureRandom.uuid }
  subject { described_class.new(claim) }

  describe '#action' do
    it 'returns :new' do
      expect(subject.action).to eq(:new)
    end
  end

  describe '#draft?' do
    it 'returns false' do
      expect(subject.draft?).to be_falsey
    end
  end

  describe '#call' do

    before { expect(subject.claim.persisted?).to be_falsey }

    context 'with a valid Claim' do
      before { expect(subject.claim).to receive(:update_claim_document_owners) }

      it 'forces validation' do
        expect(subject.claim).to receive(:force_validation=).with(true)
        subject.call
      end

      it 'returns success' do
        result = subject.call

        expect(result.success?).to be_truthy
        expect(result.error_code).to be_nil
      end

      after { expect(subject.claim.persisted?).to be_truthy }
    end

    context 'with an invalid Claim' do
      before do
        subject.claim.case_number = nil
        expect(subject.claim).not_to receive(:update_claim_document_owners)
      end

      it 'returns an error' do
        result = subject.call

        expect(result.success?).to be_falsey
        expect(result.error_code).to eq(:rollback)
      end

      after { expect(subject.claim.persisted?).to be_falsey }
    end

    context 'with an already submitted Claim' do
      before do
        allow(subject).to receive(:already_submitted?).and_return(true)
        expect(subject.claim).not_to receive(:update_claim_document_owners)
      end

      it 'returns an error' do
        result = subject.call

        expect(result.success?).to be_falsey
        expect(result.error_code).to eq(:already_submitted)
      end

      after { expect(subject.claim.persisted?).to be_falsey }
    end
  end
end
