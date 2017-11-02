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
    date_of_birth                     30.years.ago
    order_for_judicial_apportionment  false
    representation_orders             { [ FactoryBot.create(:representation_order, representation_order_date: 400.days.ago) ] }

    trait :without_reporder do
      representation_orders           { [] }
    end
  end

end
