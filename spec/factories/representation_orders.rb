# == Schema Information
#
# Table name: representation_orders
#
#  id                        :integer          not null, primary key
#  defendant_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  granting_body             :string
#  maat_reference            :string
#  representation_order_date :date
#  uuid                      :uuid
#

FactoryGirl.define do
  factory :representation_order do
    representation_order_date           { Date.today }
    maat_reference                      { Faker::Number.number(10) }
    granting_body                       { Settings.court_types[ randomly_0_or_1 ] }
  end
end



def randomly_0_or_1
  Time.now.to_i % 2
end
