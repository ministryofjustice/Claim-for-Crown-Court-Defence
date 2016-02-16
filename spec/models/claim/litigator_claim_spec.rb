require 'rails_helper'
require 'custom_matchers'

RSpec.describe Claim::LitigatorClaim, type: :model do

  describe 'validate external user has litigator role' do
    let(:claim)   { build :unpersisted_litigator_claim }

    it 'validates external user with advocate role' do
      expect(claim.external_user.is?(:advocate)).to be true
      expect(claim).to be_valid
    end

    it 'rejects external user without advocate role' do
      claim.external_user = build :external_user, :litigator, provider: claim.creator.provider
      expect(claim).not_to be_valid
      expect(claim.errors[:external_user]).to include('External user must have advocate role')
    end
  end

end
