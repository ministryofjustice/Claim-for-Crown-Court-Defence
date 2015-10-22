require 'rails_helper'

RSpec.describe StateChangePresenter do

  let(:claim)      { create(:allocated_claim) }
  let(:subject)    { StateChangePresenter.new(claim.versions.last, view) }

  describe "#change" do
    it 'returns a human readable string describing a state change' do
      expect(subject.change).to eq "Claim allocated - #{subject.created_at.strftime('%H:%M')}"
    end
  end

end