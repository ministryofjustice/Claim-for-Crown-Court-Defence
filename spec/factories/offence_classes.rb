# == Schema Information
#
# Table name: offence_classes
#
#  id           :integer          not null, primary key
#  class_letter :string(255)
#  description  :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :offence_class do
    sequence(:class_letter) { ('A'..'K').to_a.sample(1).join }
    description { Faker::Lorem.sentence }
  end
end
