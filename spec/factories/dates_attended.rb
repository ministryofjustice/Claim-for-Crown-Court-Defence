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
    date "2015-06-02 14:11:28"
    fee
  end
end
