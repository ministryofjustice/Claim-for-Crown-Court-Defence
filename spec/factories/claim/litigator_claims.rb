FactoryGirl.define do
  factory :litigator_claim, class: Claim::LitigatorClaim do

    court
    case_number { random_case_number }
    external_user { build :external_user, :litigator }
    source { 'web' }
    apply_vat  false

     after(:build) do |claim|
      claim.creator = claim.external_user
    end

    factory :unpersisted_litigator_claim do
      court         { FactoryGirl.build :court }
      external_user { FactoryGirl.build :external_user, :litigator, provider: FactoryGirl.build(:provider, :lgfs) }
      offence       { FactoryGirl.build :offence, offence_class: FactoryGirl.build(:offence_class) }
      after(:build) do |claim|
        build(:certification, claim: claim)
        claim.defendants << build(:defendant, claim: claim)
        claim.fees << build(:misc_fee, :with_date_attended, claim: claim)
        claim.expenses << build(:expense, :with_date_attended, claim: claim, expense_type: FactoryGirl.build(:expense_type))
      end
    end
  end
end
