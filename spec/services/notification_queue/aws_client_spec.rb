require 'rails_helper'

module NotificationQueue
  describe AwsClient, :slack_bot do
    subject(:aws_client) { described_class.new }

    let(:client) do
      Aws::SNS::Client.new(
        region: 'eu-west-1',
        stub_responses: { publish: {} }
      )
    end

    before { allow(Aws::SNS::Client).to receive(:new).and_return client }

    describe '#send!' do
      subject(:send!) { aws_client.send!(claim) }

      let(:claim) { create(:advocate_claim) }

      it { is_expected.to be true }
    end
  end
end
