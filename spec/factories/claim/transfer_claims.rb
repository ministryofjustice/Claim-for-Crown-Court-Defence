FactoryBot.define do
  factory :transfer_claim, aliases: [:litigator_transfer_claim], class: 'Claim::TransferClaim' do
    litigator_base_setup
    case_type { nil }

    # NOTE: transfer_detail attribute getter/setters are delegated to claim
    litigator_type { 'original' }
    elected_case { false }
    transfer_stage_id { 10 }
    transfer_date { 2.months.ago }
    case_conclusion_id { nil }

    # add (only) one transfer_fee
    after(:build) do |claim|
      claim.fees << build(:transfer_fee, claim:)
    end

    trait :with_transfer_detail do
      not_requiring_conclusion
    end

    trait :not_requiring_conclusion do
      litigator_type { 'new' }
      elected_case { true }
      transfer_stage_id { 10 }
      transfer_date { 2.months.ago }
      case_conclusion_id { nil }
    end

    trait :requiring_conclusion do
      litigator_type { 'new' }
      elected_case { false }
      transfer_stage_id { 20 }
      transfer_date { 3.months.ago }
      case_conclusion_id { 30 }
    end

    trait :graduated_fee_allocation_type do
      litigator_type { 'new' }
      elected_case { false }
      transfer_stage_id { 50 }
      case_conclusion_id { 40 }
      after(:create, &:submit!) # submission will set the allocation_type
    end

    trait :fixed_fee_allocation_type do
      litigator_type { 'new' }
      elected_case { true }
      transfer_stage_id { 10 }
      case_conclusion_id { nil }
      after(:create, &:submit!) # submission will set the allocation_type
    end

    trait :requiring_ppe do
      litigator_type { 'new' }
      elected_case { false }
      transfer_stage_id { 30 }
      case_conclusion_id { 10 }
    end

    trait :not_requiring_ppe do
      litigator_type { 'new' }
      elected_case { false }
      transfer_stage_id { 50 }
      case_conclusion_id { 40 }
    end
  end

  factory :bare_bones_transfer_claim, class: 'Claim::TransferClaim' do
    creator { association :external_user, :litigator }
    external_user { creator }
  end
end
