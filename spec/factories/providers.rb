# == Schema Information
#
# Table name: providers
#
#  id              :integer          not null, primary key
#  name            :string
#  supplier_number :string
#  provider_type   :string
#  vat_registered  :boolean
#  uuid            :uuid
#  api_key         :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :provider do
    provider_type 'chamber'
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }

    trait :firm do
      provider_type 'firm'
      sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
      sequence(:supplier_number) { |n| "#{n}-#{Time.now.to_i}" }
      vat_registered { true }
    end

    trait :chamber do
      provider_type 'chamber'
      sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    end
  end
end
