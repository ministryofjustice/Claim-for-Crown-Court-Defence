require 'rails_helper'
require 'cached_api_request'

describe CachedApiRequest do
  let(:store) { MemoryCaching.current }
  let(:url) { 'http://test.com/ping.json' }
  let(:value) { 'test value' }
  let(:cache_request) { described_class.cache(url) { value } }

  before(:each) do
    Caching.backend = store
  end

  after(:each) do
    store.clear
  end

  describe 'options' do
    subject { described_class.new(url, options) }

    context 'default set' do
      let(:options) { {} }

      it 'should have a default set of options, if none provided' do
        expect(subject.options[:ttl]).to eq(900)
        expect(subject.options[:ignore_params]).to eq(['api_key'])
      end
    end

    context 'custom set' do
      let(:options) { {ttl: 180, ignore_params: ['sorting']} }

      it 'should override default options if provided' do
        expect(subject.options[:ttl]).to eq(180)
        expect(subject.options[:ignore_params]).to eq(['sorting'])
      end
    end
  end

  describe 'url normalization and param filtering' do
    [
      %w(http://test.com                http://test.com),
      %w(http://Test.Com                http://test.com),
      %w(http://test.com?               http://test.com),
      %w(http://test.com/               http://test.com/),
      %w(http://test.com/?              http://test.com/),
      %w(http://test.com?123            http://test.com?123),
      %w(http://test.com/?123           http://test.com/?123),
      %w(http://test.com/?321           http://test.com/?321),
      %w(http://test.com?test=1         http://test.com?test=1),
      %w(http://test.com?api_key=1      http://test.com),
      %w(http://test.com?API_KEY=1      http://test.com),
      %w(http://test.com?api_key=1&a=b  http://test.com?a=b),
      %w(http://test.com?b=1&a=2        http://test.com?a=2&b=1),
      %w(http://test.com?a=1#anchor     http://test.com?a=1),
    ].each do |(url, processed_url)|
      it "should process #{url} and return #{processed_url}" do
        instance = described_class.new(url)
        expect(instance.url).to eq(processed_url)
      end
    end
  end

  describe 'writing and reading from the cache' do
    context 'caching new content' do
      it 'should write to the cache and return the content' do
        expect(store).to receive(:set).with(/api:/, /value/).once.and_call_original
        expect(cache_request).to eq(value)
      end

      it 'should cache again a stale content' do
        Timecop.freeze(1.day.ago) do
          returned = described_class.cache(url) { 'old value' }
          expect(returned).to eq('old value')
        end

        returned = described_class.cache(url) { 'new value' }
        expect(returned).to eq('new value')
      end
    end

    context 'reading from cache existing content' do
      it 'should read from the cache and return the content' do
        expect(store).to receive(:set).with(/api:/, /value/).once.and_call_original
        expect(store).to receive(:get).with(/api:/).twice.and_call_original

        returned_1 = described_class.cache(url) { 'test value' }
        returned_2 = described_class.cache(url) { 'another value' }

        expect(returned_1).to eq(returned_2)
      end
    end
  end
end
