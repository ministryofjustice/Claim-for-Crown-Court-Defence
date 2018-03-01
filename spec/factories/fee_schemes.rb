FactoryBot.define do
  factory :fee_scheme do
    name 'AGFS'
    start_date "2018-04-01 00:00:00"
    end_date nil
    number 10

    trait :nine do
      start_date '2015-01-01 00:00:00'
      end_date '2018-03-31 23:59:59'
      number 9
    end

    trait :lgfs do
      name 'LGFS'
    end
  end
end
