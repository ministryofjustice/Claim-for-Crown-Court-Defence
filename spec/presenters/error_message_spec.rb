# frozen_string_literal: true

RSpec.describe ErrorMessage do
  describe '.default_translation_file' do
    subject { described_class.default_translation_file }

    it { is_expected.to eq(Rails.root.join('config/locales/en/error_messages/claim.yml')) }
  end

  describe '.translation_file_for' do
    subject { described_class.translation_file_for(model_name) }

    let(:model_name) { 'claim' }

    context 'with default locale' do
      it { is_expected.to eq(Rails.root.join('config/locales/en/error_messages/claim.yml')) }
    end

    context 'with welsh locale and `provider`' do
      before { allow(I18n).to receive(:locale).and_return(:cy) }

      let(:model_name) { 'provider' }

      it { is_expected.to eq(Rails.root.join('config/locales/cy/error_messages/provider.yml')) }
    end
  end
end
