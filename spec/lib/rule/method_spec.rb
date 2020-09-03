# frozen_string_literal: true

RSpec.describe Rule::Method, type: :rule do
  subject(:instance) { described_class.new(:a_method, 'a source value', 'a boundary') }

  it { is_expected.to respond_to(:rule_method, :src, :bound) }

  describe '#met?' do
    subject(:met) { instance.met? }

    let(:src) { 100 }
    let(:bound) { 101 }

    context 'with a predefined method' do
      let(:instance) { described_class.new(:maximum, src, bound) }

      before { allow(instance).to receive(:maximum) }

      it 'sends rule method as message to self' do
        met
        expect(instance).to have_received(:maximum)
      end
    end

    context 'with an undefined method' do
      let(:instance) { described_class.new(:undefined, src, bound) }

      it { expect{ met }.to raise_error NoMethodError, "you need to implement rule method 'undefined'" }
    end
  end

  describe '#unmet?' do
    subject(:unmet) { instance.unmet? }

    let(:src) { 100 }
    let(:bound) { 101 }

    context 'with a predefined method' do
      let(:instance) { described_class.new(:maximum, src, bound) }

      before do
        allow(instance).to receive(:met?).and_return true
      end

      it 'sends met? message to self' do
        unmet
        expect(instance).to have_received(:met?)
      end

      it 'inverts result of met?' do
        is_expected.to be false
      end
    end
  end

  describe '#maximum' do
    subject { instance.maximum }
    let(:instance) { described_class.new(:irrelevant, src, bound) }
    let(:bound) { 100 }

    context 'when source greater than bound' do
      let(:src) { 101 }

      it { is_expected.to be_falsey }
    end

    context 'when source equal to bound' do
      let(:src) { 100 }

      it { is_expected.to be_truthy }
    end

    context 'when source less than bound' do
      let(:src) { 99 }

      it { is_expected.to be_truthy }
    end
  end

  describe '#minimum' do
    subject { instance.minimum }

    let(:instance) { described_class.new(:irrelevant, src, bound) }
    let(:bound) { 100 }

    context 'when source greater than bound' do
      let(:src) { 101 }

      it { is_expected.to be_truthy }
    end

    context 'when source equal to bound' do
      let(:src) { 100 }

      it { is_expected.to be_truthy }
    end

    context 'when source less than bound' do
      let(:src) { 99 }

      it { is_expected.to be_falsey }
    end
  end

  describe '#equal' do
    subject { instance.equal }

    let(:instance) { described_class.new(:irrelevant, src, bound) }
    let(:bound) { 100 }

    context 'when source greater than bound' do
      let(:src) { 101 }

      it { is_expected.to be_falsey }
    end

    context 'when source equal to bound' do
      let(:src) { 100 }

      it { is_expected.to be_truthy }
    end

    context 'when source less than bound' do
      let(:src) { 99 }

      it { is_expected.to be_falsey }
    end
  end

  describe '#inclusion' do
    subject { instance.inclusion }

    let(:instance) { described_class.new(:irrelevant, src, bound) }
    let(:bound) { [101, 102] }

    context 'when source is nil' do
      let(:src) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when source in bound array' do
      let(:src) { 101 }

      it { is_expected.to be_truthy }
    end

    context 'when source not in bound array' do
      let(:src) { 99 }

      it { is_expected.to be_falsey }
    end
  end

  describe '#exclusion' do
    subject { instance.exclusion }

    let(:instance) { described_class.new(:irrelevant, src, bound) }
    let(:bound) { [101, 102] }

    context 'when source is nil' do
      let(:src) { nil }

      it { is_expected.to be_truthy }
    end

    context 'when source in bound array' do
      let(:src) { 101 }

      it { is_expected.to be_falsey }
    end

    context 'when source NOT in bound array' do
      let(:src) { 99 }

      it { is_expected.to be_truthy }
    end
  end
end
