FactoryBot.define do
  factory :fee_scheme do
    name 'AGFS'
    start_date Date.new(2018, 04, 01).beginning_of_day
    end_date nil
    version 10

    trait :agfs_nine do
      start_date Date.new(2012, 04, 01).beginning_of_day
      end_date Date.new(2018, 03, 31).end_of_day
      version 9
    end

    trait :agfs_ten do
      start_date Date.new(2018, 04, 01).beginning_of_day
      end_date Date.new(2018, 12, 31).end_of_day
      version 10
    end

    trait :agfs_eleven do
      start_date Date.new(2019, 01, 01).beginning_of_day
      # start_date "2018-10-01 00:00:00"
      end_date nil
      version 11
    end

    # see doc for actual LGFS start dates
    # https://docs.google.com/document/d/12bQF1eik5-6Avss3oFtFsvuRfwjzLmj2KpcOcSMGjik
    # Note: currently using scheme 8 as scheme 9 was reversed

    # scheme 8 (default)
    # TODO: current seeds for LGFS fee schemes represent scheme 8 as 9
    # but there are no functional changes that are impacted.
    trait :lgfs do
      name 'LGFS'
      start_date Date.new(2014, 03, 20).beginning_of_day
      version 9
    end

    # trait :lgfs_nine do
    #   name 'LGFS'
    #   start_date '2015-07-01 00:00:00'
    #   version 9
    # end
  end
end
