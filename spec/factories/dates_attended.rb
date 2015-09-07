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
#  attended_item_type :string(255)
#

FactoryGirl.define do

  factory :date_attended do
    attended_item { create(:fee) }
    date    { Date.today - rand(0..10).days }
    date_to { rand(2) == 1 ? date + rand(1..3).days : nil }
  end

end
