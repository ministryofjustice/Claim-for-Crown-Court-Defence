# == Schema Information
#
# Table name: fee_types
#
#  id          :integer          not null, primary key
#  description :string
#  code        :string
#  created_at  :datetime
#  updated_at  :datetime
#  max_amount  :decimal(, )
#  calculated  :boolean          default(TRUE)
#  type        :string
#  roles       :string
#

FactoryGirl.define do
  factory :basic_fee_type, class: Fee::BasicFeeType do
    sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
    code { random_safe_code }
    calculated true
    roles ['agfs']

    trait :ppe do
      description 'Pages of prosecution evidence'
      code 'PPE'
      calculated false
    end

    trait :npw do
      description 'Number of prosecution witnesses'
      code 'NPW'
      calculated false
    end

    trait :lgfs do
      roles ['lgfs']
    end

    trait :both_fee_schemes do
      roles ['lgfs', 'agfs']
    end

    factory :misc_fee_type, class: Fee::MiscFeeType do
      sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
      code { random_safe_code }
      calculated true
      roles ['agfs']
    end

    factory :fixed_fee_type, class: Fee::FixedFeeType do
      sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
      code { random_safe_code }
      calculated true
      roles ['agfs']
    end

    factory :graduated_fee_type, class: Fee::GraduatedFeeType do
      sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
      code 'GTRL'
      calculated true
      roles ['agfs']
    end

    factory :warrant_fee_type, class: Fee::WarrantFeeType do
      description  'Warrant Fee'
      code 'XWAR'
      roles [ 'lgfs' ]
    end
  end
end

def random_safe_code
  # NOTE: use ZXX (zed plus 2 random chars) to ensure we never have a code that will cause inappropriate validations
  'Z' << ('A'..'Z').to_a.sample(2).join
end
