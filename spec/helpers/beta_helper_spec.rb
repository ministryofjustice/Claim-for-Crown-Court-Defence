require 'rails_helper'

describe BetaHelper do
  describe '#beta_test_partial' do
    subject { helper.beta_test_partial(partial_path) }

    let(:partial_path) { 'test/partial' }

    context 'when the beta testing cookie is not set' do
      it { is_expected.to eq 'test/partial_beta' }
    end

    context 'when the beta tester cookie is set to disabled' do
      before { session[:beta_testing] = 'disabled' }

      it { is_expected.to eq 'test/partial' }
    end

    context 'when the beta tester cookie is set to enabled' do
      before { session[:beta_testing] = 'enabled' }

      it { is_expected.to eq 'test/partial_beta' }
    end
  end
end
