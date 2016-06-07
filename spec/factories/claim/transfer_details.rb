
FactoryGirl.define do
  factory :transfer_detail, class: Claim::TransferDetail do
    litigator_type      'original'
    elected_case        false
    transfer_stage_id   10
    transfer_date       2.months.ago
    # case_conclusion_id  10
  end
end
