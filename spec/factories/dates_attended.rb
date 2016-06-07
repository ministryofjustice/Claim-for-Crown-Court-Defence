# == Schema Information
#
# Table name: dates_attended
#
#  id                 :integer          not null, primary key
#  date               :date
#  created_at         :datetime
#  updated_at         :datetime
#  date_to            :date
#  uuid               :uuid
#  attended_item_id   :integer
#  attended_item_type :string
#

FactoryGirl.define do
  factory :date_attended do
    attended_item { create(:basic_fee) }
    date    { 12.days.ago }
    date_to { rand(2) == 1 ? 10.days.ago : nil }

    factory :single_date_attended do
      date_to nil
    end

    factory :same_date_attended_to_as_from do
      date_to { 12.days.ago }
    end

    factory :date_range_attended do
      date_to { 10.days.ago }
    end
  end
end
