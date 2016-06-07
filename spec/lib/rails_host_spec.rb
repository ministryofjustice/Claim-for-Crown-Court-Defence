require 'rails_helper'

describe RailsHost do
  context 'api_sandbox' do
    before do
      @initial_env = ENV['ENV']
      ENV['ENV'] = 'api-sandbox'
    end

    after do
      ENV['ENV'] = @initial_env
    end

    it 'should return the rails host envirobment name' do
      expect(Rails.host.env).to eq 'api-sandbox'
    end

    it 'should return true for api_sandbox?' do
      expect(Rails.host.api_sandbox?).to be true
    end

    it 'should return false for demo' do
      expect(Rails.host.demo?).to be false
    end

    it 'should raise method missing if invalid method name' do
      expect {
        Rails.host.gibberish?
      }.to raise_error NoMethodError, /undefined method .gibberish\?/
    end
  end


  context 'staging' do
    before do
      @initial_env = ENV['ENV']
      ENV['ENV'] = 'staging'
    end

    after do
      ENV['ENV'] = @initial_env
    end

    it 'should return the rails environement host name' do
      expect(Rails.host.env).to eq 'staging'
    end

    it 'should return true for staging?' do
      expect(Rails.host.staging?).to be true
    end

    it 'should return false for demo' do
      expect(Rails.host.demo?).to be false
    end
  end
end
