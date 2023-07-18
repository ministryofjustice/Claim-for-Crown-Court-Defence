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
    shared_examples 'maximum with bound of' do |bound|
      context "with bound of #{bound.class}" do
        subject(:call) { instance.maximum }

        let(:instance) { described_class.new(:irrelevant, src, bound, options) }
        let(:options) { {} }

        context 'when source greater than bound' do
          let(:src) { bound + 1 }

          it { is_expected.to be_falsey }
        end

        context 'when source equal to bound' do
          let(:src) { bound }

          it { is_expected.to be_truthy }
        end

        context 'when source less than bound' do
          let(:src) { bound - 1 }

          it { is_expected.to be_truthy }
        end

        context 'when source nil' do
          let(:src) { nil }

          it { expect { call }.to raise_error NoMethodError }

          context 'with allow_nil: true' do
            let(:options) { { allow_nil: true } }

            it { is_expected.to be_truthy }
          end

          context 'with allow_nil: false' do
            let(:options) { { allow_nil: false } }

            it { expect { call }.to raise_error NoMethodError }
          end
        end
      end
    end

    include_examples 'maximum with bound of', 100
    include_examples 'maximum with bound of', Time.zone.today
  end

  describe '#minimum' do
    shared_examples 'minimum with bound of' do |bound|
      context "with bound of #{bound.class}" do
        subject(:call) { instance.minimum }

        let(:instance) { described_class.new(:irrelevant, src, bound, options) }
        let(:options) { {} }

        context 'when source greater than bound' do
          let(:src) { bound + 1 }

          it { is_expected.to be_truthy }
        end

        context 'when source equal to bound' do
          let(:src) { bound }

          it { is_expected.to be_truthy }
        end

        context 'when source less than bound' do
          let(:src) { bound - 1 }

          it { is_expected.to be_falsey }
        end

        context 'when source nil' do
          let(:src) { nil }

          it { expect { call }.to raise_error NoMethodError }

          context 'with allow_nil: true' do
            let(:options) { { allow_nil: true } }

            it { is_expected.to be_truthy }
          end

          context 'with allow_nil: false' do
            let(:options) { { allow_nil: false } }

            it { expect { call }.to raise_error NoMethodError }
          end
        end
      end
    end

    include_examples 'minimum with bound of', 100
    include_examples 'minimum with bound of', Time.zone.today
  end

  describe '#equal' do
    shared_examples 'equal with bound of' do |bound|
      context "with bound of #{bound.class}" do
        subject { instance.equal }

        let(:instance) { described_class.new(:irrelevant, src, bound, options) }
        let(:options) { {} }

        context 'when source greater than bound' do
          let(:src) { bound + 1 }

          it { is_expected.to be_falsey }
        end

        context 'when source equal to bound' do
          let(:src) { bound }

          it { is_expected.to be_truthy }
        end

        context 'when source less than bound' do
          let(:src) { bound - 1 }

          it { is_expected.to be_falsey }
        end

        context 'when source nil' do
          let(:src) { nil }

          it { is_expected.to be_falsey }

          context 'with allow_nil: true' do
            let(:options) { { allow_nil: true } }

            it { is_expected.to be_truthy }
          end

          context 'with allow_nil: false' do
            let(:options) { { allow_nil: false } }

            it { is_expected.to be_falsey }
          end
        end
      end
    end

    include_examples 'equal with bound of', 100
    include_examples 'equal with bound of', Time.zone.today
  end

  describe '#inclusion' do
    subject { instance.inclusion }

    let(:instance) { described_class.new(:irrelevant, src, bound, options) }
    let(:bound) { [101, 102] }
    let(:options) { {} }

    context 'when source is nil' do
      let(:src) { nil }

      it { is_expected.to be_falsey }

      context 'with allow_nil: true' do
        let(:options) { { allow_nil: true } }

        it { is_expected.to be_truthy }
      end

      context 'with allow_nil: false' do
        let(:options) { { allow_nil: false } }

        it { is_expected.to be_falsey }
      end
    end

    context 'when source in bound array' do
      let(:src) { 101 }

      it { is_expected.to be_truthy }

      context 'with allow_nil: true' do
        let(:options) { { allow_nil: true } }

        it { is_expected.to be_truthy }
      end

      context 'with allow_nil: false' do
        let(:options) { { allow_nil: false } }

        it { is_expected.to be_truthy }
      end
    end

    context 'when source not in bound array' do
      let(:src) { 99 }

      it { is_expected.to be_falsey }

      context 'with allow_nil: true' do
        let(:options) { { allow_nil: true } }

        it { is_expected.to be_falsey }
      end

      context 'with allow_nil: false' do
        let(:options) { { allow_nil: false } }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#exclusion' do
    subject { instance.exclusion }

    let(:instance) { described_class.new(:irrelevant, src, bound, options) }
    let(:bound) { [101, 102] }
    let(:options) { {} }

    context 'when source is nil' do
      let(:src) { nil }

      it { is_expected.to be_truthy }

      context 'with allow_nil: true' do
        let(:options) { { allow_nil: true } }

        it { is_expected.to be_truthy }
      end

      context 'with allow_nil: false' do
        let(:options) { { allow_nil: false } }

        it { is_expected.to be_falsey }
      end
    end

    context 'when source in bound array' do
      let(:src) { 101 }

      it { is_expected.to be_falsey }

      context 'with allow_nil: true' do
        let(:options) { { allow_nil: true } }

        it { is_expected.to be_falsey }
      end

      context 'with allow_nil: false' do
        let(:options) { { allow_nil: false } }

        it { is_expected.to be_falsey }
      end
    end

    context 'when source NOT in bound array' do
      let(:src) { 99 }

      it { is_expected.to be_truthy }

      context 'with allow_nil: true' do
        let(:options) { { allow_nil: true } }

        it { is_expected.to be_truthy }
      end

      context 'with allow_nil: false' do
        let(:options) { { allow_nil: false } }

        it { is_expected.to be_truthy }
      end
    end
  end
end
