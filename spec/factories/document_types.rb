# == Schema Information
#
# Table name: document_types
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :document_type do
    sequence(:description) { |n| "#{Faker::Lorem.sentence}-#{n}" }

    trait :representation_order do
      description 'Representation Order'
    end

    trait :indictment do
      description 'Indictment'
    end

    trait :invoice do
      description 'Invoice'
    end
  end
end
