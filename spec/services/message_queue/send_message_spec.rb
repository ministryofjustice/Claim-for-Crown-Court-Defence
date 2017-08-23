require 'rails_helper'

module MessageQueue
  describe SendMessage do
    subject(:send_message) { described_class.new(message, aws_queue_name) }

    let(:client) do
      Aws::SQS::Client.new(
        region: 'eu_west_1',
        stub_responses:
        {
          list_queues: { queue_urls:['valid_queue_name'] },
          get_queue_url: stub_queue_response,
          send_message: stub_send_response
        }
      )
    end

    let(:aws_queue_name) { 'valid_queue_name' }
    let(:stub_queue_response) { stub_response_success }
    let(:stub_send_response) {}
    let(:stub_response_success)  { { queue_url: 'http://aws_url' } }
    let(:stub_response_failure)  { Aws::SQS::Errors::NonExistentQueue.new(
                                     double('request'),
                                     double('response', :status => 400, :body => '<foo/>')
                                    )
                                 }
    let(:message) { { body: 'Claim added', attributes: { 'uuid': { data_type: 'String', string_value: SecureRandom.uuid } } } }

    before do
      allow(Aws::SQS::Client).to receive(:new).and_return client
    end

    context 'when passed a non-existant queue' do
      let(:aws_queue_name) { 'no_such_queue' }
      let(:stub_queue_response) { stub_response_failure }

      it 'raises an appropriate error' do
        expect{send_message}.to raise_error(StandardError, 'Non existing queue: no_such_queue.')
      end
    end

    describe '#send!' do
      subject(:send!) { send_message.send! }

      context 'when values are good' do
        it { is_expected.to eql true }
      end

      context 'when the message has no attributes' do
        let(:message) { { body: 'Claim added' } }

        it { is_expected.to eql true }
      end

      context 'when an error occurs (simulate someone deleting the queue mid-submission?!)' do
        let(:stub_send_response) { stub_response_failure }

        it { expect{ send! }.to raise_error(stub_response_failure) }
      end
    end
  end
end
