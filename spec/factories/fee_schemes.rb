FactoryBot.define do
  factory :fee_scheme do
    name { 'AGFS' }
    start_date { Date.new(2018, 0o4, 0o1).beginning_of_day }
    end_date { nil }
    version { 10 }

    trait :agfs_nine do
      start_date { Date.new(2016, 0o1, 0o1).beginning_of_day }
      end_date { Settings.agfs_fee_reform_release_date.end_of_day - 1.day }
      version { 9 }
    end

    trait :agfs_ten do
      start_date { Settings.agfs_fee_reform_release_date.beginning_of_day }
      end_date { Settings.agfs_scheme_11_release_date.end_of_day - 1.day }
      version { 10 }
    end

    trait :agfs_eleven do
      start_date { Settings.agfs_scheme_11_release_date.beginning_of_day }
      end_date { Settings.clar_release_date.end_of_day - 1.day }
      version { 11 }
    end

    trait :agfs_twelve do
      start_date { Settings.clar_release_date.beginning_of_day }
      end_date { Settings.agfs_scheme_13_clair_release_date.end_of_day - 1.day }
      version { 12 }
    end

    trait :agfs_thirteen do
      start_date { Settings.agfs_scheme_13_clair_release_date.beginning_of_day }
      end_date { Settings.agfs_scheme_14_section_twenty_eight.end_of_day - 1.day }
      version { 13 }
    end

    trait :agfs_fourteen do
      start_date { Settings.agfs_scheme_14_section_twenty_eight.beginning_of_day }
      end_date { Settings.agfs_scheme_15_additional_prep_fee_and_kc.end_of_day - 1.day }
      version { 14 }
    end

    trait :agfs_fifteen do
      start_date { Settings.agfs_scheme_15_additional_prep_fee_and_kc.beginning_of_day }
      end_date { Settings.agfs_scheme_16_section_twenty_eight_increase.end_of_day - 1.day }
      version { 15 }
    end

    trait :agfs_sixteen do
      start_date { Settings.agfs_scheme_16_section_twenty_eight_increase.beginning_of_day }
      end_date { nil }
      version { 16 }
    end

    trait :lgfs_nine do
      name { 'LGFS' }
      start_date { Date.new(2014, 03, 20).beginning_of_day }
      end_date { Settings.lgfs_scheme_10_clair_release_date.end_of_day - 1.day }
      version { 9 }
    end

    trait :lgfs_ten do
      name { 'LGFS' }
      start_date { Settings.lgfs_scheme_10_clair_release_date.beginning_of_day }
      end_date { Settings.lgfs_scheme_11_release_date.end_of_day - 1.day }
      version { 10 }
    end

    trait :lgfs_eleven do
      name { 'LGFS' }
      start_date { Settings.lgfs_scheme_11_release_date.beginning_of_day }
      version { 11 }
    end
  end
end
