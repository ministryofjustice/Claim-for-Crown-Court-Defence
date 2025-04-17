require 'rails_helper'

describe BetaHelper do
  describe '#beta_test_partial' do
    subject { helper.beta_test_partial(partial_path) }

    let(:partial_path) { 'test/partial' }

    context 'when beta testing is off' do
      it { is_expected.to eq partial_path }
    end

    context 'when the beta tester cookie is set' do
      before { session[:beta_testing] = 'true' }

      it { is_expected.to eq 'test/partial_beta' }
    end
  end
end
