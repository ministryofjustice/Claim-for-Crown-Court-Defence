# frozen_string_literal: true

RSpec.shared_examples 'model and indices substituter' do
  let(:key_class) { ErrorMessage::Key }

  context 'when message has substitutable parts' do
    let(:messages) { ["Enter a valid baz for the \#{bar} of the \#{foo}"] * 3 }

    context 'with rails style zero-based key' do
      let(:key) { key_class.new('foos_attributes_4_bars_attributes_3_baz') }

      it { is_expected.to eq('Enter a valid baz for the fourth bar of the fifth foo') }
    end

    context 'with custom style one-based key' do
      let(:key) { key_class.new('foo_4_bar_3_baz') }

      it { is_expected.to eq('Enter a valid baz for the third bar of the fourth foo') }
    end
  end

  context 'when message has no substitutable parts' do
    let(:messages) { ['Enter a valid baz'] * 3 }

    context 'with key not containing model indices' do
      let(:key) { key_class.new('foo_bar_baz') }

      it { is_expected.to eq('Enter a valid baz') }
    end

    context 'with key containing model indices' do
      let(:key) { key_class.new('foos_attributes_4_bars_attributes_3_baz') }

      it { is_expected.to eq('Enter a valid baz') }
    end
  end
end

RSpec.describe ErrorMessage::Message do
  subject(:message) { described_class.new(*messages, key) }

  describe '#long' do
    subject { message.long }

    it_behaves_like 'model and indices substituter'
  end

  describe '#short' do
    subject { message.short }

    it_behaves_like 'model and indices substituter'
  end

  describe '#api' do
    subject { message.api }

    it_behaves_like 'model and indices substituter'
  end
end
