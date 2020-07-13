FactoryBot.define do
  factory :fee_scheme do
    name { 'AGFS' }
    start_date { Date.new(2018, 0o4, 0o1).beginning_of_day }
    end_date { nil }
    version { 10 }

    trait :agfs_nine do
      start_date { Date.new(2016, 0o1, 0o1).beginning_of_day }
      end_date { Date.new(2018, 0o3, 31).end_of_day }
      version { 9 }
    end

    trait :agfs_ten do
      start_date { Date.new(2018, 0o4, 0o1).beginning_of_day }
      end_date { Date.new(2018, 12, 30).end_of_day }
      version { 10 }
    end

    trait :agfs_eleven do
      start_date { Date.new(2018, 12, 31).beginning_of_day }
      end_date { (Settings.agfs_scheme_12_release_date.end_of_day - 1.day) if Settings.agfs_scheme_12_enabled? }
      version { 11 }
    end

    trait :agfs_twelve do
      start_date { Settings.agfs_scheme_12_release_date.beginning_of_day }
      end_date { nil }
      version { 12 }
    end

    # scheme 8 (default)
    # TODO: current seeds for LGFS fee schemes represent scheme 8 as 9
    # but there are no functional changes that are impacted.
    trait :lgfs do
      name { 'LGFS' }
      start_date { Date.new(2014, 03, 20).beginning_of_day }
      version { 9 }
    end
  end
end
