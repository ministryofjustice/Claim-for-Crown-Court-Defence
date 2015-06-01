# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  middle_name                      :string(255)
#  last_name                        :string(255)
#  date_of_birth                    :datetime
#  representation_order_date        :datetime
#  order_for_judicial_apportionment :boolean
#  maat_reference                   :string(255)
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#

FactoryGirl.define do
  factory :defendant do
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth "2015-03-26 14:55:55"
    representation_order_date { Time.now.to_date }
    order_for_judicial_apportionment false
    maat_reference { Faker::Number.number(10) }
  end
end
