require 'rails_helper'

RSpec.describe Providers::RegenerateApiKey do
  subject { Providers::RegenerateApiKey }
  let(:provider) { create(:provider) }

  describe '.call' do
    it 'should create a new API key' do
      original_api_key = provider.api_key
      expect{ subject.call(provider) }.to change{ provider.api_key }.from(original_api_key)
    end
  end
end
