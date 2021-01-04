require 'rails_helper'
require 'caching/api_request'

RSpec.describe Caching::ApiRequest do
  let(:url) { 'http://test.com/ping.json' }

  let(:headers) { {} }
  let(:value1) { 'test value 1' }
  let(:response1) { double('Response1', headers: headers, body: value1) }
  let(:value2) { 'test value 2' }
  let(:response2) { double('Response2', headers: headers, body: value2) }

  before(:each) do
    Caching.backend = Caching::MemoryStore
  end

  after(:each) do
    Caching.clear
  end

  describe 'options' do
    subject { described_class.new(url, options) }

    context 'default set' do
      let(:options) { {} }

      it 'should have a default set of options, if none provided' do
        expect(subject.options[:ttl]).to eq(900)
        expect(subject.options[:ignore_params]).to eq([])
      end
    end

    context 'custom set' do
      let(:options) { { ttl: 180, ignore_params: ['sorting'] } }

      it 'should override default options if provided' do
        expect(subject.options[:ttl]).to eq(180)
        expect(subject.options[:ignore_params]).to eq(['sorting'])
      end
    end
  end

  describe 'url normalization and param filtering' do
    [
      %w(http://test.com http://test.com),
      %w(http://Test.Com http://test.com),
      %w(http://test.com? http://test.com),
      %w(http://test.com/ http://test.com/),
      %w(http://test.com/? http://test.com/),
      %w(http://test.com?123 http://test.com?123),
      %w(http://test.com/?123 http://test.com/?123),
      %w(http://test.com/?321 http://test.com/?321),
      %w(http://test.com?test=1 http://test.com?test=1),
      %w(http://test.com?api_key=1 http://test.com?api_key=1),
      %w(http://test.com?api_key=1&a=b http://test.com?a=b&api_key=1),
      %w(http://test.com?b=1&a=2 http://test.com?a=2&b=1),
      %w(http://test.com?a=1#anchor http://test.com?a=1)
    ].each do |(url, processed_url)|
      it "should process #{url} and return #{processed_url}" do
        instance = described_class.new(url)
        expect(instance.url).to eq(processed_url)
      end
    end
  end

  describe '.cache' do
    before do
      allow(current_store).to receive(:set).and_call_original
      allow(current_store).to receive(:get).and_call_original
    end

    let(:current_store) { Caching.backend.current }
    let(:max_age) { 3600 }

    context 'when ttl option supplied' do
      let(:headers) { {} }
      let(:options) { { ttl: 1800 } }

      context 'when cache is empty' do
        before { Caching.clear }

        it 'writes to the cache' do
          described_class.cache(url) { response1 }
          expect(current_store).to have_received(:set).with(/api:/, /test value 1/).once
        end

        it 'returns content' do
          returned = described_class.cache(url) { response1 }
          expect(returned).to eq(value1)
        end
      end

      context 'when cache content is stale' do
        before do
          over_ttl = (options[:ttl] + 1).seconds.ago
          travel_to(over_ttl) do
            described_class.cache(url) { response1 }
          end
        end

        it 'writes to the cache' do
          described_class.cache(url) { response2 }
          expect(current_store).to have_received(:set).with(/api:/, /test value 2/).once
        end

        it 'returns new content' do
          returned = described_class.cache(url) { response2 }
          expect(returned).to eq(value2)
        end
      end

      context 'when cache content is NOT stale' do
        before do
          under_ttl = (options[:ttl] - 10).seconds.ago
          travel_to(under_ttl) do
            described_class.cache(url) { response1 }
          end
        end

        it 'reads from the cache' do
          described_class.cache(url) { response1 }
          expect(current_store).to have_received(:get).with(/api:/).twice
        end

        it 'returns content from cache' do
          returned = described_class.cache(url) { response1 }
          expect(returned).to eq(value1)
        end
      end
    end

    context 'when max-age header set' do
      let(:headers) { { cache_control: "max-age=#{max_age}" } }

      context 'when cache is empty' do
        before { Caching.clear }

        it 'writes to the cache' do
          described_class.cache(url) { response1 }
          expect(current_store).to have_received(:set).with(/api:/, /test value 1/).once
        end

        it 'returns content' do
          returned = described_class.cache(url) { response1 }
          expect(returned).to eq(value1)
        end
      end

      context 'when cache content is available and not stale' do
        before do
          under_max_age = (max_age - 10).seconds.ago
          travel_to(under_max_age) do
            described_class.cache(url) { response1 }
          end
        end

        it 'reads from the cache' do
          described_class.cache(url) { response1 }
          expect(current_store).to have_received(:get).with(/api:/).twice
        end

        it 'returns content from cache' do
          returned = described_class.cache(url) { response1 }
          expect(returned).to eq(value1)
        end
      end

      context 'when cache content is stale' do
        before do
          over_max_age = (max_age + 1).seconds.ago
          travel_to(over_max_age) do
            described_class.cache(url) { response1 }
          end
        end

        it 'writes to the cache' do
          described_class.cache(url) { response2 }
          expect(current_store).to have_received(:set).with(/api:/, /test value 2/).once
        end

        it 'returns new content' do
          returned = described_class.cache(url) { response2 }
          expect(returned).to eq(value2)
        end
      end
    end

    context 'reading from cache' do
      let(:headers) { { cache_control: 'max-age=30' } }

      it 'should read from the cache and return the content' do
        expect(current_store).to receive(:set).with(/api:/, /test value 1/).once.and_call_original
        expect(current_store).not_to receive(:set).with(/api:/, /test value 2/)
        expect(current_store).to receive(:get).with(/api:/).twice.and_call_original

        returned_1 = described_class.cache(url) { response1 }
        returned_2 = described_class.cache(url) { response2 }

        expect(returned_1).to eq(returned_2)
      end
    end
  end
end
