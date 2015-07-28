# == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string(255)
#  code            :string(255)
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :fee_type do
    sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:code) { ('A'..'Z').to_a.sample(3).join }
    fee_category

    trait :basic do
      fee_category    { FeeCategory.basic || FactoryGirl.create(:basic_fee_category) }
    end

    trait :misc do
      fee_category    { FeeCategory.misc || FactoryGirl.create(:misc_fee_category) }
    end

    trait :fixed do
      fee_category    { FeeCategory.fixed || FactoryGirl.create(:fixed_fee_category) }
    end
  end


end

