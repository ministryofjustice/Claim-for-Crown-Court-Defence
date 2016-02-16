FactoryGirl.define do
  factory :litigator_claim, class: Claim::LitigatorClaim do

    court
    case_number { random_case_number }
    external_user { build :external_user, :litigator }
    source { 'web' }
    apply_vat  false

    factory :unpersisted_litigator_claim do
      court         { FactoryGirl.build :court }
      external_user { FactoryGirl.build :external_user, provider: FactoryGirl.build(:provider) }
      offence       { FactoryGirl.build :offence, offence_class: FactoryGirl.build(:offence_class) }
      after(:build) do |claim|
        build(:certification, claim: claim)
        claim.defendants << build(:defendant, claim: claim)
        claim.fees << build(:fee, :with_date_attended, claim: claim, fee_type: FactoryGirl.build(:fee_type))
        claim.expenses << build(:expense, :with_date_attended, claim: claim, expense_type: FactoryGirl.build(:expense_type))
      end
    end
  end
end
