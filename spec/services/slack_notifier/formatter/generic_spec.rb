require 'rails_helper'

RSpec.describe SlackNotifier::Formatter::Generic do
  subject(:formatter) { described_class.new }

  let(:valid_build_parameters) do
    {
      icon: ':sign-roadworks:',
      message: 'Test message',
      title: 'Test title',
      status: :pass
    }
  end

  describe '#attachment' do
    subject(:attachment) { formatter.attachment(**build_parameters) }

    context 'with valid build parameters' do
      let(:build_parameters) { valid_build_parameters }

      it { expect(attachment[:fallback]).to eq 'Test message' }
      it { expect(attachment[:title]).to eq 'Test title' }
      it { expect(attachment[:text]).to eq 'Test message' }
      it { expect(attachment[:color]).to eq '#36a64f' }
      it { expect { attachment }.to change(formatter, :message_icon).to ':sign-roadworks:' }
    end

    context 'without an icon' do
      let(:build_parameters) { valid_build_parameters.except(:icon) }

      it { expect { attachment }.not_to change(formatter, :message_icon).from ':cccd:' }
    end

    context 'with a failing status' do
      let(:build_parameters) { valid_build_parameters.merge(status: :fail) }

      it { expect(attachment[:color]).to eq '#c41f1f' }
    end

    context 'without status parameter' do
      let(:build_parameters) { valid_build_parameters.except(:status) }

      it { expect(attachment[:color]).to eq '#36a64f' }
    end

    context 'without message parameter' do
      let(:build_parameters) { valid_build_parameters.except(:message) }

      it { expect(attachment).not_to have_key(:fallback) }
      it { expect(attachment).not_to have_key(:text) }
    end

    context 'without title parameter' do
      let(:build_parameters) { valid_build_parameters.except(:title) }

      it { expect(attachment).not_to have_key(:title) }
    end
  end
end
