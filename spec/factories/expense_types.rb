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

    roles ['agfs']
    reason_set 'A'

    trait :lgfs do
      roles ['lgfs']
    end

    trait :agfs_lgfs do
      roles ['agfs', 'lgfs']
    end

    trait :reason_set_b do
      reason_set 'B'
    end
  end
end
