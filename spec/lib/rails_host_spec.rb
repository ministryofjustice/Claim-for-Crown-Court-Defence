require 'rails_helper'

RSpec.describe RailsHost, no_database_cleaner: true do
  around do |example|
    with_env(environment) { example.run }
  end

  describe '.env' do
    subject { described_class.env }

    context 'staging' do
      let(:environment) { 'staging' }

      it 'returns value of environment variable ENV' do
        is_expected.to eq('staging')
      end
    end

    context 'api-sandbox' do
      let(:environment) { 'api-sandbox' }

      it 'returns value of environment variable ENV' do
        is_expected.to eq('api-sandbox')
      end
    end

    context 'production' do
      let(:environment) { 'production' }

      it 'returns value of environment variable ENV' do
        is_expected.to eq('production')
      end
    end

    context 'gibberish' do
      let(:environment) { 'gibberish' }

      it 'returns value of environment variable ENV' do
        is_expected.to eq('gibberish')
      end
    end
  end

  describe '.host' do
    context 'valid environments' do
      context 'api-sandbox' do
        let(:environment) { 'api-sandbox' }

        it 'returns the rails host envirobment name' do
          expect(Rails.host.env).to eq 'api-sandbox'
        end

        it '#api_sandbox?' do
          expect(Rails.host.api_sandbox?).to be true
        end

        it 'returns false for dev' do
          expect(Rails.host.dev?).to be false
        end
      end

      context 'staging' do
        let(:environment) { 'staging' }

        it 'returns the rails environement host name' do
          expect(Rails.host.env).to eq 'staging'
        end

        it 'returns true for staging?' do
          expect(Rails.host.staging?).to be true
        end

        it 'returns false for dev' do
          expect(Rails.host.dev?).to be false
        end
      end

      context 'production' do
        let(:environment) { 'production' }

        it 'returns the rails environement host name' do
          expect(Rails.host.env).to eq 'production'
        end

        it 'returns true for production?' do
          expect(Rails.host.production?).to be true
        end

        it 'returns false for dev' do
          expect(Rails.host.dev?).to be false
        end
      end
    end

    context 'invalid environments' do
      let(:environment) { 'gibberish' }

      it 'raises method missing if invalid method name' do
        expect {
          Rails.host.gibberish?
        }.to raise_error NoMethodError, /undefined method .gibberish\?/
      end
    end
  end
end
