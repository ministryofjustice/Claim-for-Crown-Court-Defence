require 'rails_helper'

module MessageQueue
  describe AwsClient, slack_bot: true do
    subject(:aws_client) { described_class.new(aws_queue_id) }

    let(:client) do
      Aws::SQS::Client.new(
        region: 'eu-west-1',
        stub_responses:
          {
            list_queues: { queue_urls:['valid_queue_name'] },
            get_queue_url: stub_queue_response,
            send_message: stub_send_response,
            receive_message: stub_poll_response,
            delete_message: true
          }
      )
    end
    let(:claim) { create(:advocate_claim) }
    let(:aws_queue_id) { 'valid_queue_name' }
    let(:stub_queue_response) { stub_queue_response_success }
    let(:stub_send_response) {}
    let(:stub_poll_response) {}
    let(:stub_queue_response_success) { { queue_url: 'http://aws_url' } }
    let(:stub_queue_response_failure) do
      Aws::SQS::Errors::NonExistentQueue.new(
        double('request'),
        double('response', :status => 400, :body => '<foo/>', :empty? => false)
      )
    end
    let(:body) do
      {
        from: 'external application',
        uuid: '3d34c071-c19a-4248-93ea-6f0e91002561',
        errors: [{ error: 'PPE is a mandatory field for Claim Element of type Advocate Fee.' }],
        messages: []
      }.to_json
    end

    let(:stub_poll_response_success) do
      Aws::SQS::Types::ReceiveMessageResult.new(
        messages: [
          Aws::SQS::Types::Message.new(
            {
              message_id: "a1dc5042-e8bf-4417-a443-ed9a2c9558e6",
              receipt_handle: "AQEB4y8lIzE9G2HiEVen7vRjcmv0xFQML6VcyZYDbnOUzOHFO00yLwaZFE0flYhEv2XMTVyURrK3pRNgaHUH4KK7kFd6cGay35L58UljtEHCJNbBEHSJpuWiV98G56fz04DtTDZN5IKG4tBthDjeDlAheUBkMiiBBLESHSOlUsgGj0vu++x9IlcdjO8+pszXH8356DM3/eayvgoOq9i2yCKkSy4piO6tNX9/VHFVH0fyjIwW3knpbWJHNg2ROKs3RloXKIaBmD4boqc8DSPDx4Mx77zh/T0z3UBG/1CXzmtcXt9NfJJzSqzHus11s4l7bY6qEqIheTaQVl1rl6XF5RBN46M+qIR2i4ggV50TINn+629dP7H2J1yPDPWKJmkV/BzNuCF4fXWlsxiuleoM8v1pbQ==",
              md5_of_body: "06ca6b264e9878e64c76b3b6858a1676",
              body: body,
              attributes: {},
              md5_of_message_attributes: nil,
              message_attributes: {}
            }
          )
        ]
      )
    end

    before do
      allow(Aws::SQS::Client).to receive(:new).and_return client
      allow(Claim::BaseClaim).to receive(:find_by) { claim }
    end

    context 'when passed a non-existant queue' do
      let(:aws_queue_id) { 'no_such_queue' }
      let(:stub_queue_response) { stub_queue_response_failure }

      it 'raises an appropriate error' do
        expect { aws_client }.to raise_error(StandardError, 'Non existing queue: no_such_queue.')
      end
    end

    context 'when passed a valid queue_url' do
      let(:aws_queue_id) { 'https://aws.queue/name' }

      it { is_expected.to be_a AwsClient }
    end

    describe '#send!' do
      subject(:send!) { aws_client.send!(message) }

      let(:message) { { body: 'Claim added', attributes: { 'uuid': { data_type: 'String', string_value: SecureRandom.uuid } } } }

      context 'when values are good' do
        it { is_expected.to eql true }
      end

      context 'when the message has no attributes' do
        let(:message) { { body: 'Claim added' } }

        it { is_expected.to eql true }
      end

      context 'when an error occurs (simulate someone deleting the queue mid-submission?!)' do
        let(:stub_send_response) { stub_queue_response_failure }

        it { expect { send! }.to raise_error(stub_queue_response_failure) }
      end
    end

    describe '.poll!' do
      subject(:poll!) { aws_client.poll! }

      context 'when there are messages on the queue' do
        let(:stub_poll_response) { stub_poll_response_success }

        it { expect { poll! }.to change { InjectionAttempt.count }.by(1) }
      end
    end
  end
end
