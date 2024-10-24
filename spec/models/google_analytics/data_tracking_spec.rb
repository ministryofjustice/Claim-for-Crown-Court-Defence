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

        context 'with usage tracking accepted' do
          before { allow(described_class).to receive(:usage_name).and_return(true) }

          context 'when on staging' do
            before { allow(RailsHost).to receive(:env).and_return('staging') }

            it 'returns true' do
              expect(described_class.enabled?).to be_truthy
            end
          end

          context 'when on production' do
            before { allow(RailsHost).to receive(:env).and_return('production') }

            it 'returns true' do
              expect(described_class.enabled?).to be_truthy
            end
          end
        end

        context 'with usage tracking rejected' do
          before { allow(described_class).to receive(:usage_name).and_return(false) }

          context 'when on staging' do
            before { allow(RailsHost).to receive(:env).and_return('staging') }

            it 'returns false' do
              expect(described_class.enabled?).to be_falsy
            end
          end

          context 'when on production' do
            before { allow(RailsHost).to receive(:env).and_return('production') }

            it 'returns false' do
              expect(described_class.enabled?).to be_falsy
            end
          end
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
            described_class.track
          }.to raise_error ArgumentError, 'Uninitialized adapter'
        end
      end
    end

    describe 'type methods' do
      before do
        allow(described_class).to receive_messages(adapter: 'Adapter', usage_name: true)
        allow(Rails).to receive(:env).and_return('production'.inquiry)
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
end
