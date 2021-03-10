require 'rails_helper'

module GoogleAnalytics
  describe DataTracking do
    before do
      allow(described_class).to receive(:adapter).and_return('Adapter')
      allow(Rails).to receive(:env).and_return('production'.inquiry)
      described_class.active = true
    end

    describe '#enabled?' do
      subject { described_class.enabled? }

      context 'when host is staging' do
        before { allow(RailsHost).to receive(:env).and_return('staging') }

        it { is_expected.to be_truthy }

        context 'when active is false' do
          before { described_class.active = false }

          it { is_expected.to be_falsey }
        end
      end

      context 'when host is production' do
        before { allow(RailsHost).to receive(:env).and_return('production') }

        it { is_expected.to be_truthy }

        context 'when active is false' do
          before { described_class.active = false }

          it { is_expected.to be_falsey }
        end
      end

      context 'with no adapter set' do
        before do
          allow(described_class).to receive(:adapter).and_return(nil)
        end

        it 'returns false when host is dev' do
          allow(RailsHost).to receive(:env).and_return('dev')
          expect(described_class.enabled?).to be_falsey
        end

        it 'raises error if no adapter' do
          allow(described_class).to receive(:enabled?).and_return(true)
          expect {
            described_class.track()
          }.to raise_error ArgumentError, 'Uninitialized adapter'
        end
      end
    end

    describe '#tag_manager?' do
      subject(:tag_manager) { described_class.tag_manager? }

      context 'when the adapter is google_tag_manager' do
        before { allow(described_class).to receive(:adapter_name).and_return(:gtm) }

        it { is_expected.to be true }
      end

      context 'when the adapter is google_analytics' do
        before { allow(described_class).to receive(:adapter_name).and_return(:ga) }

        it { is_expected.to be false }
      end

      context 'when the adapter is nil' do
        before { allow(described_class).to receive(:adapter).and_return(nil) }

        it { is_expected.to be false }
      end
    end

    describe '#analytics?' do
      subject(:analytics) { described_class.analytics? }

      context 'when the adapter is google_tag_manager' do
        before { allow(described_class).to receive(:adapter_name).and_return(:gtm) }

        it { is_expected.to be false }
      end

      context 'when the adapter is google_analytics' do
        before { allow(described_class).to receive(:adapter_name).and_return(:ga) }

        it { is_expected.to be true }
      end

      context 'when the adapter is nil' do
        before { allow(described_class).to receive(:adapter).and_return(nil) }

        it { is_expected.to be false }
      end
    end
  end
end
