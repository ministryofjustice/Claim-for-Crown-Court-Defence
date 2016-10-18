require 'rails_helper'

describe Messaging::Producer do
  subject { described_class.new(queue: 'cccd-claims') }

  let(:queue) { Messaging::MockClient.queue }

  before(:each) do
    queue.clear
  end

  it 'should raise an exception when no queue config found' do
    expect {
      described_class.new(queue: 'xxx')
    }.to raise_exception(ArgumentError)
  end

  it 'should publish a message' do
    subject.publish(message: 'test message')

    expect(queue.size).to eq(1)
    expect(queue.last).to eq(target_arn: 'arn:aws:sns:eu-west-1:016649511486:cccd-claims-local', message: 'test message')
  end
end
