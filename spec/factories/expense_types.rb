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
    end

    trait :parking do
      name 'Parking'
    end

    trait :hotel_accommodation do
      name 'Hotel accommodation'
    end

    trait :train do
      name 'Train/public transport'
    end

    trait :other do
      name 'Other'
    end

    trait :travel_time do
      name 'Travel Time'
      reason_set 'B'
    end

  end
end
