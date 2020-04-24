FactoryBot.define do
  factory :case_stage do
    case_type { association(:case_type) }
    unique_code { Faker::Lorem.unique.characters(number: 5..7).upcase }
    sequence(:description) { |n| "Case stage #{n}" }
    sequence(:position) { |n| n }
    roles { %w[agfs lgfs] }
  end
end
