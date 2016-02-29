FactoryGirl.define do
  factory :litigator_claim, class: Claim::LitigatorClaim do

    court
    case_number { random_case_number }
    external_user { build :external_user, :litigator }
    source { 'web' }
    apply_vat  false
    offence    { create(:offence, :miscellaneous) } #only miscellaneous offeces valid for LGFS
    case_type { create(:case_type) }

    after(:build) do |claim|
      # build(:certification, claim: claim) - needed??
      claim.fees << build(:misc_fee, claim: claim) # fees required for valid claims
      claim.creator = claim.external_user
      populate_required_fields(claim)
    end

    factory :unpersisted_litigator_claim do
      court         { build :court }
      external_user { build :external_user, :litigator, provider: build(:provider, :lgfs) }
      offence       { build :offence, offence_class: build(:offence_class) }

      after(:build) do |claim|
        build(:certification, claim: claim)
        claim.defendants << build(:defendant, claim: claim)
        claim.fees << build(:misc_fee, :with_date_attended, claim: claim)
        claim.expenses << build(:expense, :with_date_attended, claim: claim, expense_type: build(:expense_type))
      end

    end
  end
end
