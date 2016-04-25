FactoryGirl.define do
  factory :transfer_claim, class: Claim::TransferClaim do
    litigator_base_setup
    claim_state_common_traits

    trait :trial do
      case_type  { build(:case_type, :trial) }
      first_day_of_trial 30.days.ago
      trial_concluded_at 25.days.ago
      estimated_trial_length 3
      actual_trial_length 3
    end


    after(:build) do |rec|
      if rec.transfer_detail.unpopulated?
        rec.transfer_detail = build :transfer_detail, claim: rec
      end
    end
  end
end

