require 'rails_helper'

RSpec.describe SlackNotifier::Formatter::Injection do
  subject(:formatter) { described_class.new }

  let(:claim) { create(:claim) }
  let(:valid_build_parameters) do
    {
      uuid: claim.uuid,
      from: 'external application',
      errors: []
    }
  end

  describe '#attachment' do
    subject(:attachment) { formatter.attachment(**build_parameters) }

    before do
      allow(Settings.slack).to receive(:success_icon).and_return ':tada:'
      allow(Settings.slack).to receive(:fail_icon).and_return ':sad:'
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('ENV').and_return 'test_environment'
    end

    context 'with valid build parameters' do
      let(:build_parameters) { valid_build_parameters }

      it { expect(attachment[:fallback]).to eq "Claim #{claim.case_number} successfully injected {#{claim.uuid}}" }
      it { expect(attachment[:title]).to eq 'Injection into external application succeeded' }
      it { expect(attachment[:text]).to eq claim.uuid }
      it { expect(attachment[:color]).to eq '#36a64f' }
      it { expect(attachment[:fields].pluck(:title)).to match_array(['Claim number', 'environment']) }
      it { expect { attachment }.to change(formatter, :message_icon).to ':tada:' }
    end

    context 'with errors' do
      let(:build_parameters) do
        valid_build_parameters.merge(errors: [{ 'error' => "No defendant found for Rep Order Number: '123'." }])
      end

      it { expect(attachment[:fallback]).to eq "Claim #{claim.case_number} could not be injected {#{claim.uuid}}" }
      it { expect(attachment[:title]).to eq 'Injection into external application failed' }
      it { expect(attachment[:text]).to eq claim.uuid }
      it { expect(attachment[:color]).to eq '#c41f1f' }

      it {
        expect(attachment[:fields].pluck(:title)).to match_array(['Claim number', 'environment', 'Errors'])
      }
    end

    context 'without an errors parameter' do
      let(:build_parameters) { valid_build_parameters.except(:errors) }

      it { expect(attachment[:fields].pluck(:title)).to match_array(['Claim number', 'environment']) }
    end

    context 'with an unknown claim' do
      let(:build_parameters) { valid_build_parameters.merge(uuid: 'bad-uuid') }

      it { expect(attachment[:fallback]).to eq 'Failed to inject because no claim found {bad-uuid}' }
      it { expect(attachment[:title]).to eq 'Injection into external application failed' }
      it { expect(attachment[:text]).to eq 'bad-uuid' }
      it { expect(attachment[:color]).to eq '#c41f1f' }
      it { expect(attachment[:fields].count).to eq 2 }
      it { expect { attachment }.to change(formatter, :message_icon).to ':sad:' }
    end

    context 'without a from parameter' do
      let(:build_parameters) { valid_build_parameters.except(:from) }

      it { expect(attachment[:title]).to eq 'Injection into indeterminable system succeeded' }
    end
  end
end
