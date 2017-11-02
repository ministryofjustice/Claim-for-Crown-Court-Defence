# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryBot.define do
  factory :offence do
    offence_class { OffenceClass.first || create(:offence_class) }
    sequence(:description) { |n| "#{Faker::Lorem.sentence}-#{n}" }
    sequence(:unique_code) { |n| "ABCD-#{n}" }

    trait :miscellaneous do
      description 'Miscellaneous/other'
    end

  end
end
