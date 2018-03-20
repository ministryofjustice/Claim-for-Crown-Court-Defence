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

FactoryBot.define do
  factory :offence_class do
    sequence(:class_letter)   { generate_random_unused_class_letter }
    description { Faker::Lorem.sentence }
  end

  trait :risk_based_bill_class do
    sequence(:class_letter)   { generate_random_unused_class_letter(%w{ E F H I }) }
  end

  trait :with_lgfs_offence do
    after(:create) do |record|
      offence = create :offence, :miscellaneous, offence_class: record
      offence.fee_schemes << (FeeScheme.first || create(:fee_scheme, :nine))
    end
  end
end

def generate_random_unused_class_letter(letters=%w{ A B C D E F G H I J K })
	existing_class_letters = OffenceClass.pluck(:class_letter)
	possible_class_letters = letters
	available_class_letters = possible_class_letters - existing_class_letters
	raise "All class letters have been used" if available_class_letters.empty?
	available_class_letters.sample
end

