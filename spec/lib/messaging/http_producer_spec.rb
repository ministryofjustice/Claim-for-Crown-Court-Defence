require 'rails_helper'

describe Messaging::HttpProducer do
  subject { described_class.new(client_class: client_class) }

  let(:client_class) { Messaging::MockClient }
  let(:queue) { client_class.queue }

  before(:each) do
    queue.clear
  end

  context 'publishing a message' do
    before(:each) do
      allow(ENV).to receive(:[]).with('ENV').and_return('test')
    end

    it 'should publish a message' do
      subject.publish('test message')

      expect(queue.size).to eq(1)
      expect(queue.last).to eq(post: ['test message', {content_type: :xml}])
    end
  end
end
