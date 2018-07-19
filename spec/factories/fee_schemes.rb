FactoryBot.define do
  factory :fee_scheme do
    name 'AGFS'
    start_date "2018-04-01 00:00:00"
    end_date nil
    version 10

    trait :agfs_nine do
      start_date '2015-01-01 00:00:00'
      end_date '2018-03-31 23:59:59'
      version 9
    end

    trait :agfs_ten do
      start_date "2018-04-01 00:00:00"
      end_date nil
      version 10
    end

    trait :lgfs do
      name 'LGFS'
    end

    trait :lgfs_nine do
      name 'LGFS'
      start_date '2015-01-01 00:00:00'
      version 9
    end
  end
end
