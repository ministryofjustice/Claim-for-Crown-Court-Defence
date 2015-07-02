# == Schema Information
#
# Table name: representation_orders
#
#  id                        :integer          not null, primary key
#  defendant_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  granting_body             :string(255)
#  maat_reference            :string(255)
#  representation_order_date :date
#

FactoryGirl.define do
  factory :representation_order do
    representation_order_date           { Time.now }
    maat_reference                      { Faker::Lorem.characters(10).upcase }
    granting_body                       { Settings.court_types[ randomly_0_or_1 ] }
  end
end



def randomly_0_or_1
  Time.now.to_i % 2
end
