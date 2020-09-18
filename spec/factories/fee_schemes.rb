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
      end_date { nil }
      version { 12 }
    end

    # scheme 8 (default)
    # NOTE: current seeds for LGFS fee schemes represent scheme 8 as 9
    # but there are no functional changes that are impacted.
    #
    # Following CLAR release on the 17/09/2020 the LGFS fee scheme is
    # technically scheme 9, according to the business. However, no new
    # lgfs fee scheme has been added - it probably should be - instead
    # simply adding the new "Unused material" fee type(s) without fee
    # calculation (inline with other LGFS misc fees) and validating
    # its presence using the CLAR release date compared to rep order
    # date.
    trait :lgfs do
      name { 'LGFS' }
      start_date { Date.new(2014, 03, 20).beginning_of_day }
      version { 9 }
    end
  end
end
