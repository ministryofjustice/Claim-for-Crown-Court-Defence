require 'rails_helper'

describe Claims::UpdateDraft do

  after(:all) do
    clean_database
  end

  context 'draft claim updates' do
    let(:claim) { FactoryBot.create :advocate_claim, case_number: 'A20161234' }
    let(:claim_params) { { case_number: 'A20165555' } }
    let(:validate) { true }

    subject { described_class.new(claim, params: claim_params, validate: validate) }

    it 'defines the action' do
      expect(subject.action).to eq(:edit)
    end

    it 'is a draft' do
      expect(subject.draft?).to be_truthy
    end

    context 'successful draft updates' do
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

        subject.call

        expect(subject.result.success?).to be_truthy
        expect(subject.result.error_code).to be_nil
        expect(subject.claim.case_number).to eq('A20165555')
      end
    end

    context 'unsuccessful draft updates' do
      let(:claim_params) { { case_number: '123' } }

      it 'is unsuccessful' do
        subject.call

        expect(subject.result.success?).to be_falsey
        expect(subject.result.error_code).to eq(:rollback)
      end
    end
  end
end
