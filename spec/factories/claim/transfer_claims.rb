FactoryGirl.define do
  factory :transfer_claim, class: Claim::TransferClaim do
    litigator_base_setup
    claim_state_common_traits

    # transfer_detail attributes
    litigator_type      'original'
    elected_case        false
    transfer_stage_id   10
    transfer_date       2.months.ago
    case_conclusion_id  10

    trait :trial do
      case_type  { build(:case_type, :trial) }
      first_day_of_trial 30.days.ago
      trial_concluded_at 25.days.ago
      estimated_trial_length 3
      actual_trial_length 3
    end

  end
end

