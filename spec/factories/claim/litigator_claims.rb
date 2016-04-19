FactoryGirl.define do
  factory :litigator_claim, class: Claim::LitigatorClaim do

    litigator_base_setup
    claim_state_common_traits

    after(:build) do |claim|
      claim.fees << build(:misc_fee, claim: claim) # fees required for valid claims
    end
  
    # Risk based bills are litigator claims of case type guilty plea, with offences of class E,F,H,I and a PPE of 50 or less
    # NOTE: case type is expected to be set using seeded case type of Guilty plea explicitly
    trait :risk_based_bill do
      offence { create(:offence, :miscellaneous, offence_class: create(:offence_class, :risk_based_bill_class)) }
      # after(:build) do |claim|
      #   claim.fees << build(:basic_fee, :ppe_fee, amount: 49, claim: claim)
      # end
      # submitted state needed for risk based bill allocation filter
      after(:create) { |c| c.submit! }
    end
  end
end
