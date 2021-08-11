FactoryBot.define do
  factory :stats_report, class: 'Stats::StatsReport' do
    report_name { 'management_information' }
    status { 'completed' }
    started_at { 2.minutes.ago }
    completed_at { 2.seconds.ago }

    trait :with_document do
      document do
        Rack::Test::UploadedFile.new(
          File.expand_path('spec/fixtures/files/report.csv', Rails.root),
          'text/csv'
        )
      end
    end

    trait :incomplete do
      status { 'started' }
      completed_at { nil }
    end

    trait :error do
      status { 'error' }
    end

    trait :other_report do
      report_name { 'other_report' }
    end
  end
end
