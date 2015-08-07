# == Schema Information
#
# Table name: dates_attended
#
#  id         :integer          not null, primary key
#  date       :datetime
#  fee_id     :integer
#  created_at :datetime
#  updated_at :datetime
#  date_to    :datetime
#


FactoryGirl.define do

  factory :date_attended do
    attended_item { create(:fee) }
    date    { Time.current - rand(0..10).days }
    date_to { rand(2) == 1 ? date + rand(1..3).days : nil }
  end

end
