FactoryGirl.define do
  factory :organisation do
    trait :firm do
      organisation_type 'firm'
      sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
      sequence(:supplier_number) { |n| "#{n}-#{Time.now.to_i}" }
      vat_registered { true }
    end

    trait :chamber do
      organisation_type 'chamber'
      sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    end
  end
end
