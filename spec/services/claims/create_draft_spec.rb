require 'rails_helper'

describe Claims::CreateDraft do

  after(:all) do
    clean_database
  end

  context 'draft claim creation' do
    let(:claim) { FactoryGirl.build :advocate_claim }
    let(:validate) { true }

    subject { described_class.new(claim, validate: validate) }

    it 'defines the action' do
      expect(subject.action).to eq(:new)
    end

    it 'defines the google analytics tokens' do
      expect(subject.ga_args).to eq %w(event claim draft created)
    end

    it 'is a draft' do
      expect(subject.draft?).to be_truthy
    end

    context 'successful draft creations' do
      context 'validation enabled' do
        let(:validate) { true }

        it 'forces validation if indicated' do
          allow(subject.claim).to receive(:force_validation=).with(true)
          subject.call
        end
      end

      context 'validation not enabled' do
        let(:validate) { false }

        it 'forces validation if indicated' do
          allow(subject.claim).to receive(:force_validation=).with(false)
          subject.call
        end
      end

      it 'is successful' do
        expect(subject.claim.persisted?).to be_falsey

        subject.call

        expect(subject.result.success?).to be_truthy
        expect(subject.result.error_code).to be_nil
        expect(subject.claim.persisted?).to be_truthy
      end
    end

    context 'unsuccessful draft creations' do
      it 'is unsuccessful' do
        claim.case_number = nil

        expect(subject.claim.persisted?).to be_falsey

        subject.call

        expect(subject.result.success?).to be_falsey
        expect(subject.result.error_code).to eq(:rollback)
        expect(subject.claim.persisted?).to be_falsey
      end

      it 'is unsuccessful for an already submitted claim' do
        expect(subject.claim.persisted?).to be_falsey
        allow(subject).to receive(:already_saved?).and_return(true)

        subject.call

        expect(subject.result.success?).to be_falsey
        expect(subject.result.error_code).to eq(:already_saved)
        expect(subject.claim.persisted?).to be_falsey
      end
    end
  end
end
