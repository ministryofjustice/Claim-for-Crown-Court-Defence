FactoryGirl.define do
  factory :litigator_claim, class: Claim::LitigatorClaim do

    litigator_base_setup
    claim_state_common_traits

    after(:build) do |claim|
      claim.fees << build(:misc_fee, :lgfs, claim: claim) # fees required for valid claims
    end

    trait(:without_defendants) do
      after(:create) do |claim|
        claim.defendants.clear
      end

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

    trait :graduated_fee do
      after(:build) do |claim|
        fee_type = create :graduated_fee_type
        case_type = create :case_type, :graduated_fee, fee_type_code: fee_type.unique_code
        claim.case_type = case_type
      end
    end

    trait :fixed_fee do
      after(:build) do |claim|
        fee_type = create :fixed_fee_type
        case_type = create :case_type, :fixed_fee, fee_type_code: fee_type.unique_code
        claim.case_type = case_type
      end
    end

  end
end




