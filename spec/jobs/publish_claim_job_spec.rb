require 'rails_helper'

RSpec.describe PublishClaimJob, type: :job do

  let(:message_class) { Messaging::ClaimMessage }
  let(:claim) { instance_double(Claim::BaseClaim, uuid: '123-456') }

  it 'should create a message and publish to the queue' do
    expect(message_class).to receive(:new).with(claim).and_call_original
    expect_any_instance_of(message_class).to receive(:publish)
    described_class.perform_now(claim)
  end
end
