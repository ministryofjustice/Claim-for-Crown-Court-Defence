# frozen_string_literal: true

RSpec.describe Caching::Response do
  subject(:instance) { described_class.new(response) }
  let(:response) { instance_double('mock_response', body: 'body content', headers: 'header content') }

  describe '#validate!' do
    context 'with a valid response object' do
      it { is_expected.to be_a described_class }
    end

    context 'with invalid response object' do
      let(:response) { instance_double('mock_response') }

      it { expect{ instance }.to raise_error ArgumentError, /must implement/}
    end
  end

  describe '#body' do
    subject(:body) { instance.body }

    it { is_expected.to eql 'body content' }
  end

  describe '#headers' do
    subject(:headers) { instance.headers }

    it { is_expected.to eql 'header content' }
  end

  describe '#ttl' do
    subject(:ttl) { instance.ttl }

    let(:response) { instance_double('mock_response', body: 'body content', headers: headers ) }

    context 'with max-age Cache-Control header' do
      let(:headers) { { cache_control: 'max-age=900, private, re-validate'} }

      it { is_expected.to eql 900 }
    end

    context 'without max-age Cache-Control header' do
      let(:headers) { { cache_control: 'no-cache' } }

      it { is_expected.to eql 0 }
    end
  end
end
