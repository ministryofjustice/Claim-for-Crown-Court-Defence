require 'rails_helper'

RSpec.describe ExternalUsers::AvailableClaimTypes do
  subject { ExternalUsers::AvailableClaimTypes }

  before(:each) do
    allow(Settings).to receive(:allow_lgfs_interim_fees?).and_return true
    allow(Settings).to receive(:allow_lgfs_transfer_fees?).and_return true
  end

  describe '.call' do
    context 'when context is Provider' do
      let(:agfs)    { build :provider, :agfs }
      let(:lgfs)    { build :provider, :lgfs }
      let(:both)    { build :provider, :agfs_lgfs }

      it 'should return advocate claim for agfs' do
        expect(subject.call(agfs)).to match_array([ Claim::AdvocateClaim ])
      end

      it 'should return litigator claim for lgfs' do
        expect(subject.call(lgfs)).to match_array([Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim])
      end

      it 'should return both claim types for agfs-lgfs' do
        expect(subject.call(both)).to match_array([Claim::AdvocateClaim, Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim])
      end
    end

    context 'when context is ExternalUser' do
      let(:advocate)            { build(:external_user, :advocate) }
      let(:litigator)           { build(:external_user, :litigator) }
      let(:admin)               { build(:external_user, :admin) }
      let(:advocate_litigator)  { build(:external_user, :advocate_litigator) }

      it 'returns advocate claims for advocates' do
        expect(subject.call(advocate)).to match_array([Claim::AdvocateClaim])
      end

      it 'returns litigator claims for litigators' do
        expect(subject.call(litigator)).to match_array([Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim])
      end

      it 'returns both types of claims for admin' do
        expect(subject.call(admin)).to match_array([Claim::AdvocateClaim, Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim])
      end

      it 'returns both types of claims for advocate_litigators' do
        expect(subject.call(advocate_litigator)).to match_array([Claim::AdvocateClaim, Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim])
      end
    end
  end
end
