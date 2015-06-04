# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string(255)
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryGirl.define do
  factory :offence do
    offence_class { OffenceClass.first || create(:offence_class) }
    sequence(:description) { |n| "#{Faker::Lorem.sentence}-#{n}" }
  end
end
