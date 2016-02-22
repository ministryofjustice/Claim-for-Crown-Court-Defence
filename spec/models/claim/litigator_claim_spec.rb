require 'rails_helper'
require 'custom_matchers'

RSpec.describe Claim::LitigatorClaim, type: :model do

  let(:claim)   { build :unpersisted_litigator_claim }


  describe 'validate external user has litigator role' do
    it 'validates external user with litigator role' do
      expect(claim.external_user.is?(:litigator)).to be true
      expect(claim).to be_valid
    end

    it 'rejects external user without litigator role' do
      claim.external_user = build :external_user, :advocate, provider: claim.creator.provider
      expect(claim).not_to be_valid
      expect(claim.errors[:external_user]).to include('must have litigator role')
    end
  end

  describe 'validate creator provider is in LGFS fee scheme' do
    it 'rejects creators whose provider is only agfs' do
      claim.creator = build(:external_user, provider: build(:provider, :agfs))
      expect(claim).not_to be_valid
      expect(claim.errors[:creator]).to eq(["must be from a provider with the LGFS fee scheme"])
    end

    it 'accepts creators whose provider is only lgfs' do
      claim.creator = build(:external_user, provider: build(:provider, :lgfs))
      expect(claim).to be_valid
    end
    
    it 'accepts creators whose provider is both agfs and lgfs' do
      claim.creator = build(:external_user, provider: build(:provider, :agfs_lgfs))
      expect(claim).to be_valid
    end
  end

end
