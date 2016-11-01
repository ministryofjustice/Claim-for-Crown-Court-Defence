# == Schema Information
#
# Table name: expense_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#  roles      :string
#  reason_set :string
#

FactoryGirl.define do
  factory :expense_type do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    unique_code { ('A'..'Z').to_a.sample(5).join }

    roles ['agfs', 'lgfs']
    reason_set 'A'

    trait :lgfs do
      roles ['lgfs']
    end

    trait :agfs do
      roles ['agfs']
    end

    trait :reason_set_b do
      reason_set 'B'
    end

    trait :car_travel do
      name 'Car travel'
      unique_code 'CAR'
    end

    trait :parking do
      name 'Parking'
      unique_code 'PARK'
    end

    trait :hotel_accommodation do
      name 'Hotel accommodation'
      unique_code 'HOTEL'
    end

    trait :train do
      name 'Train/public transport'
      unique_code 'TRAIN'
    end

    trait :road_tolls do
      name 'Road or tunnel tolls'
      unique_code 'ROAD'
    end

    trait :cab_fares do
      name 'Cab fares'
      unique_code 'CABF'
    end

    trait :subsistence do
      name 'Subsistence'
      unique_code 'SUBS'
    end

    trait :travel_time do
      name 'Travel time'
      unique_code 'TRAVL'
      reason_set 'B'
    end
  end
end
