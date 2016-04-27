# require 'awesome_print'

FactoryGirl.define do
  factory :transfer_claim, class: Claim::TransferClaim do
    litigator_base_setup
    claim_state_common_traits

    # transfer_detail attributes
    litigator_type      'original'
    elected_case        false
    transfer_stage_id   10
    transfer_date       2.months.ago
    case_conclusion_id  nil

    trait :trial do
      case_type  { build(:case_type, :trial) }
      first_day_of_trial 30.days.ago
      trial_concluded_at 25.days.ago
      estimated_trial_length 3
      actual_trial_length 3
    end

    # TODO: rather than short circuiting the "transfer brain" this trait should apply expected attribute logic
    trait :graduated_fee_allocation_type do
      litigator_type      'new'
      elected_case        false
      transfer_stage_id   50
      case_conclusion_id  40
      after(:create) do |claim|
        claim.submit! # submission will set the allocation_type
      end
    end

    # TODO: rather than short circuiting the "transfer brain" this trait should apply expected attribute logic
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
