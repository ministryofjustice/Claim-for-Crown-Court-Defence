# == Schema Information
#
# Table name: offence_classes
#
#  id           :integer          not null, primary key
#  class_letter :string
#  description  :string
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :offence_class do
    sequence(:class_letter)     { |n| letter_hash[n % 11] }
    description { Faker::Lorem.sentence }
  end
end

def letter_hash
  %w{ A B C D E F G H I J K}
end
