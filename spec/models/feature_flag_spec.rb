require 'rails_helper'

RSpec.describe FeatureFlag do
  describe '.feature_flag' do
    let(:feature_flag) { described_class.feature_flag }

    context 'when a feature_flag record exists with non-default values' do
      before do
        described_class.feature_flag.update!(enable_new_monarch: true)
      end

      it 'returns the existing record' do
        expect(feature_flag.enable_new_monarch?).to be true
      end
    end

    context 'when there is no feature_flag record' do
      before { described_class.delete_all }

      it 'generates one using default database values' do
        expect(feature_flag.enable_new_monarch?).to be false
      end
    end
  end
end
