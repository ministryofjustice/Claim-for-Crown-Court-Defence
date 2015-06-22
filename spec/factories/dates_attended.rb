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
    date { Time.current - rand(0..10).days }
    fee
  end
end
