FactoryBot.define do
  factory :interim_claim_info do
    claim
    warrant_fee_paid false

    trait :with_warrant_fee_paid do
      warrant_fee_paid true
      warrant_issued_date InterimClaimInfo::MINIMUM_PERIOD_SINCE_ISSUED.ago
      warrant_executed_date { warrant_issued_date + 5.days }
    end
  end
end
