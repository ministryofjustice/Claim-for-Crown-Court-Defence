require 'rails_helper'

describe API::Entities::CCR::AdaptedHardshipFee, type: :adapter do
  subject(:response) { JSON.parse(described_class.represent(adapted_hardship_fees).to_json).deep_symbolize_keys }

  let(:claim) { create(:advocate_hardship_claim, :agfs_scheme_9, case_stage: build(:case_stage, :trial_not_concluded)) }
  let(:adapted_hardship_fees) { ::CCR::Fee::HardshipFeeAdapter.new(claim) }

  it 'exposes expected json key-value pairs' do
    expect(response).to include(
      bill_type: 'AGFS_ADVANCE',
      bill_subtype: 'AGFS_HARDSHIP'
    )
  end

  context '#amount' do
    subject(:amount) { response[:amount] }

    it 'exposes amount' do
      expect(response.keys).to include(:amount)
    end

    context 'scheme 9' do
      before do
        claim.basic_fees.find_by(fee_type: Fee::BaseFeeType.find_by(unique_code: 'BABAF')).update(quantity: 1, rate: 10)
        claim.fees << build(:basic_fee, :daf_fee, quantity: 1, rate: 1, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :daj_fee, quantity: 1, rate: 1, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :dah_fee, quantity: 1, rate: 1, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :noc_fee, quantity: 1, rate: 2, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :ndr_fee, quantity: 1, rate: 3, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :npw_fee, quantity: 20, amount: 50, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :ppe_fee, quantity: 1000, amount: 1000, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :cav_fee, quantity: 1, rate: 100, claim: claim) # not added to hardship - a CCR misc fee that is NOT injected
        claim.fees << build(:basic_fee, :saf_fee, quantity: 1, rate: 100, claim: claim) # not added to hardship - a CCR misc fee that IS injected
        claim.fees << build(:basic_fee, :pcm_fee, quantity: 1, rate: 100, claim: claim) # not added to hardship - a CCR misc fee that IS injected
      end

      it 'sums amounts of BABAF, BADAF, BADAJ, BADAH, BANOC, BANDR, BANPW, BAPPE fees' do
        is_expected.to eql '1068.0'
      end
    end

    context 'scheme 10+' do
      let(:claim) { create(:advocate_hardship_claim, :agfs_scheme_10, case_stage: build(:case_stage, :trial_not_concluded)) }

      before do
        claim.basic_fees.find_by(fee_type: Fee::BaseFeeType.find_by(unique_code: 'BABAF')).update(quantity: 1, rate: 10)
        claim.fees << build(:basic_fee, :dat_fee, quantity: 1, rate: 1, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :noc_fee, quantity: 1, rate: 2, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :ndr_fee, quantity: 1, rate: 3, claim: claim) # add to hardship
        claim.fees << build(:basic_fee, :cav_fee, quantity: 1, rate: 100, claim: claim) # not added to hardship - a CCR misc fee that is NOT injected
        claim.fees << build(:basic_fee, :saf_fee, quantity: 1, rate: 100, claim: claim) # not added to hardship - a CCR misc fee that IS injected
        claim.fees << build(:basic_fee, :pcm_fee, quantity: 1, rate: 100, claim: claim) # not added to hardship - a CCR misc fee that IS injected
      end

      it 'sums amounts of BABAF, BADAT, BANOC, BANDR fees' do
        is_expected.to eql '16.0'
      end
    end
  end
end
