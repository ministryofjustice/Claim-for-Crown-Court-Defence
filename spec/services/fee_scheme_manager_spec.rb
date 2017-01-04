require 'rails_helper'

describe FeeSchemeManager do

  describe '.version' do

    it 'returns :lgfs_v6 for Litigator Final Claims' do
      claim = build :litigator_claim
      expect(FeeSchemeManager.version(claim)).to eq :lgfs_v6
    end

    it 'returns :lgfs_v6 for Litigator Transfer claims' do
      claim = build :transfer_claim
      expect(FeeSchemeManager.version(claim)).to eq :lgfs_v6
    end

    it 'returns :lgfs_v6 for Litigator Interim claims' do
      claim = build :interim_claim
      expect(FeeSchemeManager.version(claim)).to eq :lgfs_v6
    end

    it 'returns :agfs_v9 for dates before AGFS_FEE_SCHEME_DATES' do
      claim = build :advocate_claim
      expect(claim).to receive(:earliest_representation_order_date).and_return(FeeSchemeManager::AGFS_FEE_SCHEME_10_DATE - 1.day)
      expect(FeeSchemeManager.version(claim)).to eq :agfs_v9
    end

    it 'returns :agfs_v10 for rep order date on the date of validity' do
      claim = build :advocate_claim
      expect(claim).to receive(:earliest_representation_order_date).and_return(FeeSchemeManager::AGFS_FEE_SCHEME_10_DATE)
      expect(FeeSchemeManager.version(claim)).to eq :agfs_v10
    end

    it 'returns :agfs_v10 for rep order date after the date of validity' do
      claim = build :advocate_claim
      expect(claim).to receive(:earliest_representation_order_date).and_return(FeeSchemeManager::AGFS_FEE_SCHEME_10_DATE + 1.day)
      expect(FeeSchemeManager.version(claim)).to eq :agfs_v10
    end

    it 'returns :agfs_v9 on gamma even for rep order date after the date of validity' do
      claim = build :advocate_claim
      expect(claim).to receive(:earliest_representation_order_date).and_return(FeeSchemeManager::AGFS_FEE_SCHEME_10_DATE)
      allow(RailsHost).to receive(:env).and_return('gamma')
      expect(FeeSchemeManager.version(claim)).to eq :agfs_v9
    end
  end
end