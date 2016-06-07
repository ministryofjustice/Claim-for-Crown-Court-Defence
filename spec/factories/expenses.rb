# == Schema Information
#
# Table name: expenses
#
#  id              :integer          not null, primary key
#  expense_type_id :integer
#  claim_id        :integer
#  location        :string
#  quantity        :float
#  rate            :decimal(, )
#  amount          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#  reason_id       :integer
#  reason_text     :string
#  schema_version  :integer
#  distance        :integer
#  mileage_rate_id :integer
#  date            :date
#  hours           :integer
#  vat_amount      :decimal(, )      default(0.0)
#

FactoryGirl.define do
  factory :expense do
    expense_type
    claim
    location Faker::Address.city
    amount "9.99"
    reason_id 2 # reason set B doesn't have ID 1
    date 3.days.ago

    trait :car_travel do
      expense_type { build :expense_type, :car_travel }
      distance 27
      mileage_rate_id 2
    end

    trait :parking do
      expense_type { build :expense_type, :parking }
      location nil
    end

    trait :hotel_accommodation do
      expense_type { build :expense_type, :hotel_accommodation }
    end

    trait :train do
      expense_type { build :expense_type, :train }
    end

    trait :travel_time do
      expense_type { build :expense_type, :travel_time }
      hours 4
    end

    trait :with_date_attended do
      after(:build) do |expense|
        expense.dates_attended << build(:date_attended, attended_item: expense)
      end
    end

    trait :with_date_range_attended do
      after(:build) do |expense|
        expense.dates_attended << build(:date_range_attended, attended_item: expense)
      end
    end

    trait :with_single_date_attended do
      after(:build) do |expense|
        expense.dates_attended << build(:single_date_attended, attended_item: expense)
      end
    end

    trait :with_same_date_attended_to_as_from do
      after(:build) do |expense|
        expense.dates_attended << build(:same_date_attended_to_as_from, attended_item: expense)
      end
    end

    trait :with_multiple_dates_attended do
      after(:build) do |expense|
        expense.dates_attended << build(:date_attended, attended_item: expense)
        expense.dates_attended << build(:date_attended, attended_item: expense, date: 5.days.ago, date_to: 3.days.ago)
      end
    end

    trait :random_values do
      quantity { rand(1..10) }
      rate { rand(1.0..9.99) }
      amount { quantity * rate}
    end

    trait :lgfs do
      expense_type { create(:expense_type, :lgfs) }
    end
  end
end
