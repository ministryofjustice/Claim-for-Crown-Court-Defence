# frozen_string_literal: true

RSpec.shared_examples 'long message fallback' do
  context 'with simple key' do
    let(:key) { :foo }
    let(:error) { 'bar' }

    it { is_expected.to eq('Foo bar') }
  end

  context 'with single nested rails style keys' do
    let(:key) { 'foos_attributes_4_bar' }
    let(:error) { 'baz' }

    it { is_expected.to eq('Foo 4 bar baz') }
  end

  context 'with triple nested rails style keys' do
    let(:key) { 'foos_attributes_4_bars_attributes_3_bazs_attributes_2_bing' }
    let(:error) { 'blank' }

    it { is_expected.to eq('Foo 4 bar 3 baz 2 bing blank') }
  end

  context 'with single nested custom style keys' do
    let(:key) { 'foo_4_bar' }
    let(:error) { 'baz' }

    it { is_expected.to eq('Foo 4 bar baz') }
  end

  context 'with triple nested custom style keys' do
    let(:key) { 'foo_4_bar_3_baz_2_bing' }
    let(:error) { 'blank' }

    it { is_expected.to eq('Foo 4 bar 3 baz 2 bing blank') }
  end
end

RSpec.describe ErrorMessage::Fallback do
  subject(:fallback) { described_class.new(key, error) }

  let(:key) { :name }
  let(:error) { 'cannot_be_blank' }

  describe '#messages' do
    subject(:messages) { fallback.messages }

    let(:key) { :key_name }
    let(:error) { 'error_message' }

    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(['Key name error message', 'Error message', 'Key name error message']) }
  end

  describe '#long' do
    subject { fallback.long }

    it_behaves_like 'long message fallback'
  end

  describe '#short' do
    subject { fallback.short }

    let(:key) { :foo }
    let(:error) { 'bar_cannot_be_blank' }

    it { is_expected.to eq('Bar cannot be blank') }
  end

  describe '#api' do
    subject { fallback.api }

    it_behaves_like 'long message fallback'
  end
end
