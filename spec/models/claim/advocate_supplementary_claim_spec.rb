require 'rails_helper'

RSpec.describe Claim::AdvocateSupplementaryClaim, type: :model do
  let(:claim) { build(:advocate_supplementary_claim) }

  it_behaves_like 'a base claim'

  specify { expect(subject.external_user_type).to eq(:advocate) }
  specify { expect(subject.requires_case_type?).to be_falsey }
  specify { expect(subject.agfs?).to be_truthy }
  specify { expect(subject.final?).to be_falsey }
  specify { expect(subject.interim?).to be_falsey }

  describe '#eligible_advocate_categories' do
    let(:advocate_categories) { instance_double(Array) }

    it 'sends message to FetchEligibleAdvocateCategories' do
      expect(Claims::FetchEligibleAdvocateCategories).to receive(:for).with(claim).and_return(advocate_categories)
      expect(claim.eligible_advocate_categories).to eq(advocate_categories)
    end
  end

  describe '#eligible_misc_fee_types' do
    let(:service) { instance_double(Claims::FetchEligibleMiscFeeTypes) }
    let(:misc_fee_types) { instance_double(Array) }

    it 'sends message to FetchEligibleMiscFeeTypes' do
      expect(Claims::FetchEligibleMiscFeeTypes).to receive(:new).with(claim).and_return(service)
      expect(service).to receive(:call).and_return(misc_fee_types)
      expect(claim.eligible_misc_fee_types).to eq(misc_fee_types)
    end
  end

  describe '#cleaner' do
    let(:claim) { build(:advocate_supplementary_claim, with_misc_fee: false) }
    context 'destroys invalid fee types' do
      before do
        seed_fee_types
      end

      context 'when there are ineligible misc fees on the claim' do
        before { claim.misc_fees << misc_fees }
        let(:eligible_fee) { build(:misc_fee, :mispf_fee) }
        let(:ineligible_fee) { build(:misc_fee, :minbr_fee) }
        let(:another_ineligible_fee) { build(:misc_fee, :minbr_fee) }
        let(:misc_fees) { [eligible_fee, ineligible_fee, another_ineligible_fee] }

        specify 'removes the ineligible misc fee' do
          expect { claim.save }.to change(claim.misc_fees, :size).from(3).to(1)
          unique_codes = claim.misc_fees.map(&:fee_type).map(&:unique_code)
          expect(unique_codes).to_not include(ineligible_fee.fee_type.unique_code)
        end

        specify 'saves the eligible fee' do
          expect { claim.save }.to change(claim.misc_fees, :count).from(0).to(1)
          unique_codes = claim.misc_fees.map(&:fee_type).map(&:unique_code)
          expect(unique_codes).to match_array(eligible_fee.fee_type.unique_code)
        end
      end

    end
  end
end
