# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string
#  last_name                        :string
#  date_of_birth                    :date
#  order_for_judicial_apportionment :boolean
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  uuid                             :uuid
#

FactoryBot.define do
  factory :defendant do
    first_name                        { Faker::Name.first_name }
    last_name                         { Faker::Name.last_name }
    date_of_birth                     { 30.years.ago }
    order_for_judicial_apportionment  { false }
    claim

    transient do
      scheme { nil }
      representation_order_date { scheme_date_for(scheme) }
    end

    representation_orders { FactoryBot.create_list(:representation_order, 1, representation_order_date:) }

    trait :without_reporder do
      representation_orders { [] }
    end
  end
end
