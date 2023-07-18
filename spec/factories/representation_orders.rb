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
    representation_order_date           { Time.zone.today }
    maat_reference                      { Faker::Number.between(from: 4_000_000, to: 9_999_999) }
  end
end
