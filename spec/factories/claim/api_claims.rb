include ClaimFactoryHelpers

FactoryBot.define do
  factory :api_advocate_claim, class: Claim::AdvocateClaim do
    # Attempt to create minimal API submitted claims
    # the main claim factories would have needed too much hacking to
    # remove the default values required for a web based submission

    external_user
    court
    case_type
    offence
    case_number { random_case_number }
    advocate_category 'QC'
    source { 'api' }

    trait :with_scheme_nine_offence do
      offence { association(:offence, :with_fee_scheme_nine) }
    end

    trait :with_scheme_ten_offence do
      offence { association(:offence, :with_fee_scheme_ten) }
    end

    trait :with_no_offence do
      case_type { association(:case_type, :fixed_fee) }
      offence nil
    end

    after(:build) { |claim| set_creator(claim) }

  end
end
