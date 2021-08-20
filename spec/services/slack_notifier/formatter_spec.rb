require 'rails_helper'

RSpec.describe SlackNotifier::Formatter do
  subject(:formatter) { described_class.new }

  describe '#ready_to_send' do
    subject { formatter.ready_to_send }

    context 'when #build has not been called' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#payload' do
    subject(:payload) { formatter.payload }

    let(:build_parameters) do
      {
        icon: ':sign-roadworks:',
        message: 'Test message',
        title: 'Test title',
        status: :pass
      }
    end
    let(:first_attachment) { payload[:attachments].first }

    before { formatter.build(**build_parameters) }

    it { expect(payload[:icon_emoji]).to eq ':sign-roadworks:' }
    it { expect(first_attachment[:fallback]).to eq 'Test message' }
    it { expect(first_attachment[:title]).to eq 'Test title' }
    it { expect(first_attachment[:text]).to eq 'Test message' }
    it { expect(first_attachment[:color]).to eq '#36a64f' }
    it { expect(formatter.ready_to_send).to be_truthy }

    context 'with a failing status' do
      let(:build_parameters) { super().merge(status: :fail) }

      it { expect(first_attachment[:color]).to eq '#c41f1f' }
    end

    context 'without icon parameter' do
      let(:build_parameters) { super().except(:icon) }

      # TODO: Default icon?
      it { expect(payload[:icon_emoji]).to be_nil }
      it { expect(formatter.ready_to_send).to be_truthy }
    end

    context 'without status parameter' do
      let(:build_parameters) { super().except(:status) }

      it { expect(first_attachment[:color]).to be_nil }

      it do
        pending 'TODO: Remove keys with nil value from payload sent to Slack'
        expect(first_attachment).not_to have_key(:color)
      end
    end

    context 'without message parameter' do
      let(:build_parameters) { super().except(:message) }

      it { expect(first_attachment[:fallback]).to be_nil }
      it { expect(first_attachment[:text]).to be_nil }
      it { expect(formatter.ready_to_send).to be_truthy }

      it do
        pending 'TODO: Remove keys with nil value from payload sent to Slack'
        expect(first_attachment).not_to have_key(:fallback)
      end

      it do
        pending 'TODO: Remove keys with nil value from payload sent to Slack'
        expect(first_attachment).not_to have_key(:text)
      end
    end

    context 'without title parameter' do
      let(:build_parameters) { super().except(:title) }

      it { expect(first_attachment[:title]).to be_nil }
      it { expect(formatter.ready_to_send).to be_truthy }

      it do
        pending 'TODO: Remove keys with nil value from payload sent to Slack'
        expect(first_attachment).not_to have_key(:title)
      end
    end
  end

  describe '#build' do
    subject(:build) { formatter.build(**build_parameters) }

    context 'with valid parameters' do
      let(:build_parameters) do
        {
          icon: ':sign-roadworks:',
          message: 'Test message',
          title: 'Test title',
          status: :pass
        }
      end

      it { expect { build }.to change(formatter, :ready_to_send).to true }
    end
  end
end
