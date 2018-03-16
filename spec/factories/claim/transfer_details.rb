
FactoryBot.define do
  factory :transfer_detail, class: Claim::TransferDetail do
    litigator_type 'original'
    elected_case false
    transfer_stage_id 10
    transfer_date 2.months.ago

    trait :with_specific_mapping do
      litigator_type 'new'
      elected_case false
      transfer_stage_id 10
      case_conclusion_id 50
    end

    trait :with_wildcard_mapping do
      litigator_type 'new'
      elected_case true
      transfer_stage_id 10
      case_conclusion_id 20
    end

    trait :with_invalid_combo do
      litigator_type 'new'
      elected_case false
      transfer_stage_id 30
      case_conclusion_id 50
    end

    trait :with_ppe_required do
      litigator_type 'new'
      elected_case false
      transfer_stage_id 30
      case_conclusion_id 10
    end

    trait :with_ppe_not_required do
      litigator_type 'new'
      elected_case false
      transfer_stage_id 20
      case_conclusion_id 30
    end
  end
end
