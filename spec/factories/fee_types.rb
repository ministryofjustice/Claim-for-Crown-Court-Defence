# == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string
#  code            :string
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  max_amount      :decimal(, )
#  calculated      :boolean          default(TRUE)
#  type            :string
#

FactoryGirl.define do
  factory :basic_fee_type, class: Fee::BasicFeeType do
    sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    calculated true

    trait :ppe do
      description 'Pages of prosecution evidence'
      code 'PPE'
      calculated false
    end

    trait :npw do
      description 'Numberof prosecution witnesses'
      code 'NPW'
      calculated false
    end
  end

  factory :misc_fee_type, class: Fee::MiscFeeType do
    sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    calculated true
  end

  factory :fixed_fee_type, class: Fee::FixedFeeType do
    sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    calculated true  
  end
end

