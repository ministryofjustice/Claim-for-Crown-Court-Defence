require 'rails_helper'

RSpec.describe SlackNotifier::Formatter::Transitioner do
  subject(:formatter) { described_class.new }

  let(:valid_build_parameters) { { processed: 100, failed: 0 } }

  describe '#attachment' do
    subject(:attachment) { formatter.attachment(**build_parameters) }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('ENV').and_return 'test'
    end

    context 'with valid build parameters' do
      let(:build_parameters) { valid_build_parameters }

      it { expect(attachment[:fallback]).to eq '100 transitions processed (0 failed)' }
      it { expect(attachment[:title]).to eq '[test] Stale claim archiver completed' }
      it { expect(attachment[:text]).to eq '100 transitions processed (0 failed)' }
      it { expect(attachment[:color]).to eq '#36a64f' }
      it { expect { attachment }.to change(formatter, :message_icon).to ':smile_cat:' }
    end

    context 'with failed jobs' do
      let(:build_parameters) { valid_build_parameters.merge(failed: 3) }

      it { expect(attachment[:fallback]).to eq '100 transitions processed (3 failed)' }
      it { expect(attachment[:title]).to eq '[test] Stale claim archiver completed with failures' }
      it { expect(attachment[:text]).to eq '100 transitions processed (3 failed)' }
      it { expect(attachment[:color]).to eq '#c41f1f' }
      it { expect { attachment }.to change(formatter, :message_icon).to ':scream_cat:' }
    end
  end
end
