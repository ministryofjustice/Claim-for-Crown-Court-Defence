require 'rails_helper'

RSpec.describe Subscribers::Base, type: :subscriber do
  describe 'instance' do
    let(:args) { ['some_event.lib', 2.minutes.ago, 5.seconds.ago, SecureRandom.uuid, {}] }
    subject(:instance) { described_class.new(*args) }

    before do
      allow(ActiveSupport::Notifications::Event).to receive(:new)
    end

    it 'creates an event with the provided arguments and processes it' do
      expect(ActiveSupport::Notifications::Event).to receive(:new).with(*args).once
      expect { instance }.to raise_error(NotImplementedError)
    end
  end
end
