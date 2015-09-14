# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  claim_id    :integer
#  fee_type_id :integer
#  quantity    :integer
#  amount      :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#  uuid        :uuid
#

FactoryGirl.define do
  factory :fee do
    claim
    fee_type
    quantity 1
    amount "250"

    trait :with_date_attended do
      after(:build) do |fee|
        fee.dates_attended << build(:date_attended, attended_item: fee)
      end
    end

    trait :random_values do
      quantity { rand(1..15) }
      amount   { rand(100.00..9999.99).round(2) }
    end

    trait :basic do
      fee_type { FactoryGirl.create :fee_type, :basic }
    end

    trait :misc do
      fee_type { FactoryGirl.create :fee_type, :misc }
    end

    trait :fixed do
      fee_type { FactoryGirl.create :fee_type, :fixed }
    end

    trait :all_zero do
      quantity 0
      amount 0
    end

    trait :from_api do
      claim         { FactoryGirl.create :claim, source: 'api' }
    end

    trait :baf_fee do
      fee_type      { FactoryGirl.create :fee_type, description: 'Basic Fee', code: 'BAF' }
    end

    trait :daf_fee do
      fee_type      { FactoryGirl.create :fee_type, description: 'Daily Attendance Fee (3 to 40)', code: 'DAF' }
    end

    trait :dah_fee do
      fee_type      { FactoryGirl.create :fee_type, description: 'Daily Attendance Fee (41 to 50)', code: 'DAH' }
    end

    trait :daj_fee do
      fee_type      { FactoryGirl.create :fee_type, description: 'Daily Attendance Fee (50+)', code: 'DAJ' }
    end

    trait :pcm_fee do
      fee_type      { FactoryGirl.create :fee_type, description: 'Plea and Case Management Hearing', code: 'PCM' }
    end


  end

end
