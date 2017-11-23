require 'rails_helper'

RSpec.describe InjectionResponseService, slack_bot: true do
  subject(:irs) { described_class.new(json) }

  let(:claim) { create :claim }
  let(:invalid_json) { { "errors": [], 'claim_id': '1234567', "messages":[] } }
  let(:valid_json_with_invalid_uuid) { { "errors":[], "uuid":'b08cfd61-9999-8888-7777-651477183efb', "messages":[{'message':'Claim injected successfully.'}]} }
  let(:valid_json_on_success) { { "errors":[], "uuid":claim.uuid, "messages":[{'message':'Claim injected successfully.'}]} }
  let(:valid_json_on_failure) { { "errors":[ {'error':"No defendant found for Rep Order Number: '123456432'."} ],"uuid":claim.uuid,"messages":[] } }

  context 'when initialized with' do
    describe 'valid json' do
      let(:json) { valid_json_on_success }

      it { is_expected.to be_a_kind_of(described_class) }
    end

    describe 'invalid json' do
      let(:json) { invalid_json }

      it { expect { subject }.to raise_error ParseError, 'Invalid JSON string' }
    end
  end

  describe '#run!' do
    subject(:irs_run!) { irs.run! }

    context 'when injection succeeded' do
      let(:json) { valid_json_on_success }

      it { is_expected.to be true }
    end

    context 'when injection failed' do
      let(:json) { valid_json_on_failure }

      it { is_expected.to be true }
    end

    context 'when claim uuid cannot be matched' do
      let(:json) { valid_json_with_invalid_uuid }

      it { is_expected.to be false }
      it 'logs an error' do
        expect(LogStuff).to receive(:info).with('InjectionResponseService::NonExistentClaim',
                                                action: 'run!',
                                                uuid: 'b08cfd61-9999-8888-7777-651477183efb')
        irs_run!
      end
    end
  end
end
