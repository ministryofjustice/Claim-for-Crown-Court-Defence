require 'rails_helper'

describe Messaging::ClaimMessage do
  let(:claim) { create(:authorised_claim) }

  subject { described_class.new(claim) }

  it 'should have a message' do
    expect(subject.message).to match(/<cbo:claim_uuid>#{claim.uuid}<\/cbo:claim_uuid>/)
  end

  context 'when using SNS producer' do
    before do
      Messaging::ClaimMessage.producer = Messaging::SNSProducer.new(client_class: Messaging::MockClient, queue: 'cccd-claims')
    end

    it 'should publish' do
      expect_any_instance_of(Messaging::SNSProducer).to receive(:publish)
      subject.publish
    end
  end

  context 'when using HTTP producer' do
    before do
      Messaging::ClaimMessage.producer = Messaging::HttpProducer.new(client_class: Messaging::MockClient)
    end

    it 'should publish' do
      expect_any_instance_of(Messaging::HttpProducer).to receive(:publish)
      subject.publish
    end
  end
end
