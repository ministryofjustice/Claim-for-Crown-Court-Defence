FactoryGirl.define do
  factory :litigator_claim, class: Claim::LitigatorClaim do

    court
    case_number         { random_case_number }
    creator             { build :external_user, :litigator }
    external_user       nil
    source              { 'web' }
    apply_vat           false
    offence             { create(:offence, :miscellaneous) } #only miscellaneous offences valid for LGFS
    case_type           { create(:case_type) }

    after(:build) do |claim|
      claim.fees << build(:misc_fee, claim: claim) # fees required for valid claims
    end

    factory :unpersisted_litigator_claim do
      court         { build :court }
      external_user nil
      creator       { build :external_user, :litigator, provider: build(:provider, :lgfs) }
      offence       { build :offence, offence_class: build(:offence_class) }
    end
  end
end

