require 'rails_helper'
require 'custom_matchers'

RSpec.describe Claim::LitigatorClaim, type: :model do

  describe 'validate external user has litigator role' do
    let(:claim)   { build :unpersisted_litigator_claim }

    it 'validates external user with litigator role' do
      expect(claim.external_user.is?(:litigator)).to be true
      expect(claim).to be_valid
    end

    it 'rejects external user without litigator role' do
      claim.external_user = build :external_user, :advocate, provider: claim.creator.provider
      expect(claim).not_to be_valid
      expect(claim.errors[:external_user]).to include('External user must have litigator role')
    end
  end

end
