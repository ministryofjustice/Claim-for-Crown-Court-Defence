require 'rails_helper'

RSpec.describe Claims::ExternalUserActions do
  describe '.all' do
    subject { described_class.all }

    it { is_expected.to eq ['Apply for redetermination', 'Request written reasons'] }
  end

  describe '#available_for' do
    subject { described_class.available_for(claim) }

    context 'when the claim has not been redetermined yet' do
      let(:claim) { create :advocate_claim }

      it { is_expected.to eq ['Request written reasons'] }
    end

    context 'when the claim has already been redetermined' do
      let(:claim) { create :deterministic_claim, :redetermination }

      it { is_expected.to eq ['Apply for redetermination', 'Request written reasons'] }
    end
  end
end
