require 'rails_helper'

module GoogleAnalytics
  describe DataTracking do
    describe '#enabled?' do
      subject { described_class.enabled? }
      before do
        allow(Rails).to receive(:env).and_return('production'.inquiry)
      end

      context 'with an adapter set' do
        before do
          allow(described_class).to receive(:adapter).and_return('Adapter')
        end

        %w(staging gamma production).each do |host|
          it "returns true when host is #{host}" do
            allow(RailsHost).to receive(:env).and_return(host)
            expect(described_class.enabled?).to be_truthy
          end
        end
      end

      context 'with no adapter set' do
        before do
          allow(described_class).to receive(:adapter).and_return(nil)
        end

        it 'returns false when host is demo' do
          allow(RailsHost).to receive(:env).and_return('gamma')
          expect(described_class.enabled?).to be_falsey
        end

        it 'raises if not adapter' do
          allow(described_class).to receive(:enabled?).and_return(true)
          expect{
            described_class.track()
          }.to raise_error ArgumentError, 'Uninitialized adapter'
        end
      end
    end

    describe 'type methods' do
      before do
        allow(described_class).to receive(:adapter).and_return('Adapter')
        allow(Rails).to receive(:env).and_return('production'.inquiry)
      end

      context '#tag_manager?' do
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

      context '#analytics?' do
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
end
