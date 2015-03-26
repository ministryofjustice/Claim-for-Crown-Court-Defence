FactoryGirl.define do
  factory :defendant do
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth "2015-03-26 14:55:55"
    representation_order_date "2015-03-26 14:55:55"
    order_for_judicial_apportionment false
    maat_ref_nos { Faker::Number.number(10) }
  end
end
