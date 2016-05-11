require 'rails_helper'

describe Claims::CreateClaim do

  after(:all) do
    clean_database
  end

  context 'claim creation' do
    let(:claim) { FactoryGirl.build :advocate_claim }
    subject { described_class.new(claim) }

    it 'defines the action' do
      expect(subject.action).to eq(:new)
    end

    it 'defines the google analytics tokens' do
      expect(subject.ga_args).to eq %w(event claim submit started)
    end

    it 'is not a draft' do
      expect(subject.draft?).to be_falsey
    end

    context 'successful creations' do
      it 'forces validation' do
        allow(subject.claim).to receive(:force_validation=).with(true)
        subject.call
      end

      it 'is successful' do
        expect(subject.claim.persisted?).to be_falsey
        expect(subject.claim).to receive(:update_claim_document_owners)

        subject.call

        expect(subject.result.success?).to be_truthy
        expect(subject.result.error_code).to be_nil
        expect(subject.claim.persisted?).to be_truthy
      end
    end

    context 'unsuccessful creations' do
      it 'is unsuccessful' do
        claim.case_number = nil

        expect(subject.claim.persisted?).to be_falsey
        expect(subject.claim).not_to receive(:update_claim_document_owners)

        subject.call

        expect(subject.result.success?).to be_falsey
        expect(subject.result.error_code).to eq(:rollback)
        expect(subject.claim.persisted?).to be_falsey
      end

      it 'is unsuccessful for an already submitted claim' do
        allow(subject).to receive(:already_submitted?).and_return(true)

        expect(subject.claim.persisted?).to be_falsey
        expect(subject.claim).not_to receive(:update_claim_document_owners)

        subject.call

        expect(subject.result.success?).to be_falsey
        expect(subject.result.error_code).to eq(:already_submitted)
        expect(subject.claim.persisted?).to be_falsey
      end
    end
  end
end
