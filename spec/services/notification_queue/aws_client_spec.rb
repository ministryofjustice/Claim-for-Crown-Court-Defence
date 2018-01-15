require 'rails_helper'

module NotificationQueue
  describe AwsClient, slack_bot: true do
    subject(:aws_client) { described_class.new }

    let(:client) do
      Aws::SNS::Client.new(
        region: 'eu_west_1',
        stub_responses:
          {
            publish: stub_publish_response
          }
      )
    end
    let(:stub_publish_response) {}

    before { allow(Aws::SNS::Client).to receive(:new).and_return client }

    describe '#send!' do
      subject(:send!) { aws_client.send!(claim) }

      let(:claim) { create(:claim) }

      it { is_expected.to eql true}
    end
  end
end
