require 'rails_helper'

RSpec.describe Claim::AdvocateSupplementaryClaim do
  let(:claim) { build(:advocate_supplementary_claim) }

  it_behaves_like 'a base claim'
  it_behaves_like 'a claim delegating to case type'
  it_behaves_like 'an AGFS claim'
  it_behaves_like 'uses claim cleaner', Cleaners::AdvocateSupplementaryClaimCleaner

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
end
