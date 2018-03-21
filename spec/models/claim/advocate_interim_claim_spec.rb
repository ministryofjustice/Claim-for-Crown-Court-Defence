require 'rails_helper'

RSpec.describe Claim::AdvocateInterimClaim, type: :model do
  specify { expect(subject.external_user_type).to eq(:advocate) }
  specify { expect(subject.requires_case_type?).to be_falsey }
  specify { expect(subject.agfs?).to be_truthy }
  specify { expect(subject.final?).to be_falsey }
  specify { expect(subject.interim?).to be_truthy }

  describe '#eligible_advocate_categories' do
    let(:categories) { double(:mocked_categories_result) }
    let(:claim) { build(:advocate_interim_claim) }

    specify {
      expect(Claims::FetchEligibleAdvocateCategories).to receive(:for).with(claim).and_return(categories)
      expect(claim.eligible_advocate_categories).to eq(categories)
    }
  end
end
