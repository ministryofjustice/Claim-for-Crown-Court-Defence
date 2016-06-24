
FactoryGirl.define do
  factory :statistic, class: Stats::Statistic do
    date Date.today
    report_name 'my_report'
    claim_type 'Claim::AdvocateClaim'
    value_1  1029
  end
end

