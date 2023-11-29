RSpec.describe Schedule::PollInjectionResponses do
  subject(:poller) { described_class.new }

  describe '#perform' do
    subject(:perform) { poller.perform }

    let(:queue) { :test_queue }
    let(:aws_client) { instance_double(MessageQueue::AwsClient) }

    before do
      allow(Settings.aws).to receive(:response_queue).and_return(queue)
      allow(MessageQueue::AwsClient).to receive(:new).with(queue).and_return(aws_client)
      allow(aws_client).to receive(:poll!).and_return([])
    end

    it do
      perform
      expect(aws_client).to have_received(:poll!)
    end
  end
end
