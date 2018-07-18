FactoryBot.define do
  factory :advocate_interim_claim, class: Claim::AdvocateInterimClaim do
    advocate_base_setup
    case_type nil

    after(:build) do |claim|
      claim.creator = claim.external_user
    end

    trait :submitted do
      after(:create) { |c| c.submit! }
    end

    trait :without_fees do
      after(:build) do |claim|
        claim.fees.destroy_all
      end
    end

    trait :agfs_scheme_9 do
      after(:create) do |claim|
        claim.defendants.each do |defendant|
          defendant
            .representation_orders
            .update_all(representation_order_date: Settings.agfs_fee_reform_release_date-10)
        end
      end
    end

    trait :agfs_scheme_10 do
      after(:create) do |claim|
        claim.defendants.each do |defendant|
          defendant
            .representation_orders
            .update_all(representation_order_date: Settings.agfs_fee_reform_release_date)
        end
      end
    end
  end
end
