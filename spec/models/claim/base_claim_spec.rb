require 'rails_helper'

module Claim
  describe BaseClaim do

    let(:advocate)   { create :external_user, :advocate }
    let(:agfs_claim) { create(:advocate_claim) }
    let(:lgfs_claim) { create(:litigator_claim) }
    
    it 'raises if I try to instantiate a base claim' do
      expect {
        claim = BaseClaim.new(external_user: advocate, creator: advocate)
      }.to raise_error ::Claim::BaseClaimAbstractClassError, 'Claim::BaseClaim is an abstract class and cannot be instantiated'
    end

    describe '#owner' do
      it 'returns creator for lgfs claims' do
        expect(lgfs_claim.owner).to eql lgfs_claim.creator
      end
      it 'returns external_user for agfs claims' do
        expect(agfs_claim.owner).to eql agfs_claim.external_user
      end
    end

    describe '#agfs?' do
      it 'returns true if claim is advocate/agfs claim, false for litigator/lgfs claims' do
        expect(agfs_claim.agfs?).to eql true
        expect(lgfs_claim.agfs?).to eql false
      end
    end

    describe '#lgfs?' do
      it 'returns true if claim is litigator/lgfs claim, false for advocate/agfs claims' do
        expect(lgfs_claim.lgfs?).to eql true
        expect(agfs_claim.lgfs?).to eql false
      end
    end

  end

end