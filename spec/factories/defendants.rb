# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  middle_name                      :string(255)
#  last_name                        :string(255)
#  date_of_birth                    :date
#  order_for_judicial_apportionment :boolean
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  uuid                             :uuid
#

FactoryGirl.define do
  factory :defendant do
    first_name                        { Faker::Name.first_name }
    middle_name                       { Faker::Name.first_name }
    last_name                         { Faker::Name.last_name }
    date_of_birth                     30.years.ago
    order_for_judicial_apportionment  false
    representation_orders             { [ FactoryGirl.create(:representation_order) ] }
  end

end
