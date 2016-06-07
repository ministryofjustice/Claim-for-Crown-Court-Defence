# == Schema Information
#
# Table name: stats_reports
#
#  id           :integer          not null, primary key
#  report_name  :string
#  report       :string
#  status       :string
#  started_at   :datetime
#  completed_at :datetime
#

FactoryGirl.define do
  factory :stats_report, class: Stats::StatsReport do
    report_name 'management_information'
    report 'report contents'
    status 'completed'
    started_at { 2.minutes.ago }
    completed_at { 2.seconds.ago }

    trait :incomplete do
      status 'started'
      completed_at nil
    end

    trait :error do
      status 'error'
    end

    trait :other_report do
      report_name 'other_report'
    end
  end
end
