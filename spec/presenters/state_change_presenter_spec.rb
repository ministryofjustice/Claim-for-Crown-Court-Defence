require 'rails_helper'

RSpec.describe StateChangePresenter do

  let(:claim)      { create(:allocated_claim) }
  let(:subject)    { StateChangePresenter.new(claim.versions.last, view) }

  describe "#change" do
    it 'returns a human readable string describing a state change' do
      allow(subject).to receive(:current_user_persona).and_return('CaseWorker')
      expect(subject.change).to eq "Claim allocated"
    end
  end
end
