# require 'awesome_print'

FactoryGirl.define do
  factory :transfer_claim, class: Claim::TransferClaim do
    litigator_base_setup
    claim_state_common_traits

    # note: transfer_detail attribute getter/setters are delegated to claim
    litigator_type      'original'
    elected_case        false
    transfer_stage_id   10
    transfer_date       2.months.ago
    case_conclusion_id  nil

    # add (only) one transfer_fee
    after(:build) do |claim|
      claim.fees << build(:transfer_fee, claim: claim)
    end

    trait :trial do
      case_type  { build(:case_type, :trial) }
      first_day_of_trial 30.days.ago
      trial_concluded_at 25.days.ago
      estimated_trial_length 3
      actual_trial_length 3
    end

    trait :graduated_fee_allocation_type do
      litigator_type      'new'
      elected_case        false
      transfer_stage_id   50
      case_conclusion_id  40
      after(:create) do |claim|
        claim.submit! # submission will set the allocation_type
      end
    end

    trait :fixed_fee_allocation_type do
      litigator_type      'new'
      elected_case        true
      transfer_stage_id   10
      case_conclusion_id  nil
      after(:create) do |claim|
        claim.submit! # submission will set the allocation_type
      end
    end

  end
end
