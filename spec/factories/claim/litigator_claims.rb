FactoryGirl.define do
  factory :litigator_claim, class: Claim::LitigatorClaim do

    litigator_base_setup
    claim_state_common_traits

    after(:build) do |claim|
      claim.fees << build(:misc_fee, :lgfs, claim: claim) # fees required for valid claims
    end

    # Risk based bills are litigator claims of case type guilty plea, with offences of class E,F,H,I and a graduated fee PPE/quantity of 50 or less
    trait :risk_based_bill do
      offence { create(:offence, :miscellaneous, offence_class: create(:offence_class, :risk_based_bill_class)) }
      after(:build) do |claim|
        claim.fees << build(:graduated_fee, :guilty_plea_fee, quantity: 49, claim: claim)
      end
      after(:create) { |c| c.submit! }
    end

    trait :without_fees do
      after(:build) do |claim|
        claim.fees.destroy_all
      end
    end

  end
end
