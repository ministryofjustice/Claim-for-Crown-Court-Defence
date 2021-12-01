require 'rails_helper'

RSpec.describe ThinkstCanary do
  describe '.configure' do
    let(:configuration) { described_class.configuration }

    it { expect { |block| described_class.configure(&block) }.to yield_with_args(configuration) }
  end
end
