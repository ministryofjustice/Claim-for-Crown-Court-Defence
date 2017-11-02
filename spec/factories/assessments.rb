
# creates a claim and associated assessment
#
FactoryBot.define do

  factory :assessment do
    skip_create

    initialize_with do
      claim = create :submitted_claim
      claim.assessment
    end

    trait :random_amounts do
      expenses { rand(0.0..999.99).round(2) }
      fees { rand(0.0..999.99).round(2) }
      disbursements { rand(0.0..999.99).round(2) }
    end

    # saving makes sure we update the total
    after(:create) do |assessment|
      assessment.save!
    end
  end

end