require 'rails_helper'

RSpec.describe InjectionResponseService, slack_bot: true do
  subject(:irs) { described_class.new(json) }

  let(:claim) { create :claim }
  let(:injection_attempt) { claim.injection_attempts.last }

  let(:invalid_json) { { "errors": [], 'claim_id': '1234567', "messages":[] } }
  let(:valid_json_with_invalid_uuid) { { "from":'external application', "errors":[], "uuid":'b08cfd61-9999-8888-7777-651477183efb', "messages":[{ 'message':'Claim injected successfully.' }] } }
  let(:valid_json_on_success) { { "from":'external application', "errors":[], "uuid":claim.uuid, "messages":[{ 'message':'Claim injected successfully.' }] } }
  let(:valid_json_on_failure) { { "from":'external application', "errors":[{ 'error':"No defendant found for Rep Order Number: '123456432'." }, { 'error':error_message }],"uuid":claim.uuid,"messages":[] } }
  let(:error_message) { 'Another injection error.' }

  shared_examples 'creates injection attempts' do
    it 'returns true' do
      is_expected.to be true
    end

    it 'creates an injection attempt' do
      expect { run! }.to change(InjectionAttempt, :count).by(1)
    end
  end

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
    subject(:run!) { irs.run! }

    context 'when injection succeeded' do
      let(:json) { valid_json_on_success }
      include_examples 'creates injection attempts'

      it 'marks injection as succeeded' do
        run!
        expect(injection_attempt.succeeded).to be_truthy
      end

      it 'does not send a slack message' do
        run!
        expect(a_request(:post, 'https://hooks.slack.com/services/fake/endpoint')).not_to have_been_made
      end
    end

    context 'when injection failed' do
      let(:json) { valid_json_on_failure }
      include_examples 'creates injection attempts'

      it 'marks injection as failed' do
        run!
        expect(injection_attempt.succeeded).to be_falsey
      end

      it 'sends a slack message' do
        run!
        expect(a_request(:post, 'https://hooks.slack.com/services/fake/endpoint')).to have_been_made.times(1)
      end

      it 'adds error messages from the response' do
        run!
        expect(injection_attempt.error_messages).to be_present
        expect(injection_attempt.error_messages).to be_an Array
        expect(injection_attempt.error_messages).to include("No defendant found for Rep Order Number: '123456432'.",'Another injection error.')
      end

      context 'with a known, ignorable, error' do
        let(:error_message) { '<blahblah>already exist<blahblah>' }

        it 'does not send a slack message' do
          run!
          expect(a_request(:post, 'https://hooks.slack.com/services/fake/endpoint')).not_to have_been_made
        end
      end
    end

    context 'when claim uuid cannot be matched' do
      let(:json) { valid_json_with_invalid_uuid }

      it { is_expected.to be false }

      it 'logs an error' do
        expect(LogStuff).to receive(:info).with('InjectionResponseService::NonExistentClaim',
                                                action: 'run!',
                                                uuid: 'b08cfd61-9999-8888-7777-651477183efb')
        run!
      end
    end
  end
end
