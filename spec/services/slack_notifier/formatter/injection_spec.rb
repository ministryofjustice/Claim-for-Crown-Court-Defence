require 'rails_helper'

RSpec.describe SlackNotifier::Formatter::Injection do
  subject(:formatter) { described_class.new }

  let(:claim) { create :claim }
  let(:valid_build_parameters) do
    {
      uuid: claim.uuid,
      from: 'external application',
      errors: []
    }
  end

  it_behaves_like 'a slack notifier formatter'

  describe '#payload' do
    subject(:payload) { formatter.payload }

    let(:first_attachment) { payload[:attachments].first }

    before do
      allow(Settings.slack).to receive(:success_icon).and_return ':tada:'
      allow(Settings.slack).to receive(:fail_icon).and_return ':sad:'
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('ENV').and_return 'test_environment'

      formatter.build(**build_parameters)
    end

    context 'with valid build parameters' do
      let(:build_parameters) { valid_build_parameters }

      it { expect(payload[:icon_emoji]).to eq ':tada:' }
      it { expect(first_attachment[:fallback]).to eq "Claim #{claim.case_number} successfully injected {#{claim.uuid}}" }
      it { expect(first_attachment[:title]).to eq 'Injection into external application succeeded' }
      it { expect(first_attachment[:text]).to eq claim.uuid }
      it { expect(first_attachment[:color]).to eq '#36a64f' }
      it { expect(first_attachment[:fields].count).to eq 2 }
      it { expect(formatter.ready_to_send).to be_truthy }
    end

    context 'with errors' do
      let(:build_parameters) do
        valid_build_parameters.merge(errors: [{ 'error' => "No defendant found for Rep Order Number: '123'." }])
      end

      it { expect(payload[:icon_emoji]).to eq ':sad:' }
      it { expect(first_attachment[:fallback]).to eq "Claim #{claim.case_number} could not be injected {#{claim.uuid}}" }
      it { expect(first_attachment[:title]).to eq 'Injection into external application failed' }
      it { expect(first_attachment[:text]).to eq claim.uuid }
      it { expect(first_attachment[:color]).to eq '#c41f1f' }
      it { expect(first_attachment[:fields].count).to eq 3 }
      it { expect(formatter.ready_to_send).to be_truthy }
    end

    context 'with an unknown claim' do
      let(:build_parameters) { valid_build_parameters.merge(uuid: 'bad-uuid') }

      it { expect(payload[:icon_emoji]).to eq ':sad:' }
      it { expect(first_attachment[:fallback]).to eq 'Failed to inject because no claim found {bad-uuid}' }
      it { expect(first_attachment[:title]).to eq 'Injection into external application failed' }
      it { expect(first_attachment[:text]).to eq 'bad-uuid' }
      it { expect(first_attachment[:color]).to eq '#c41f1f' }
      it { expect(first_attachment[:fields].count).to eq 2 }
      it { expect(formatter.ready_to_send).to be_truthy }
    end

    context 'without a from parameter' do
      let(:build_parameters) { valid_build_parameters.except(:from) }

      it { expect(first_attachment[:title]).to eq 'Injection into indeterminable system succeeded' }
    end
  end
end
