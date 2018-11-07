# == Schema Information
#
# Table name: representation_orders
#
#  id                        :integer          not null, primary key
#  defendant_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  maat_reference            :string
#  representation_order_date :date
#  uuid                      :uuid
#

FactoryBot.define do
  factory :representation_order do
    representation_order_date           { Date.today }
    maat_reference                      { Faker::Number.between(from = 4000000, to = 9999999999) }
  end
end
