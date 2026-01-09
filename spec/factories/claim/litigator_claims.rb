FactoryBot.define do
  factory :litigator_claim, aliases: [:litigator_final_claim], class: 'Claim::LitigatorClaim' do
    litigator_base_setup

    after(:build) do |claim|
      claim.fees << build(:misc_fee, :lgfs, claim:) # fees required for valid claims
    end

    trait(:without_defendants) do
      after(:create) do |claim|
        claim.defendants.clear
      end
    end

    # Risk based bills are litigator claims of case type guilty plea, with offences of class E,F,H,I and a graduated fee PPE/quantity of 50 or less
    trait :risk_based_bill do
      offence do
        association :offence, :miscellaneous, offence_class: association(:offence_class, :risk_based_bill_class)
      end
      after(:build) do |claim|
        claim.fees << build(:graduated_fee, :guilty_plea_fee, quantity: 49, claim:)
      end

      after(:create, &:submit!)
    end

    trait :without_fees do
      after(:build) do |claim|
        claim.fees.destroy_all
      end

      after(:create) do |claim|
        claim.fees.destroy_all
      end
    end

    trait :graduated_fee do
      after(:build) do |claim|
        fee_type = create(:graduated_fee_type)
        case_type = create(:case_type, :graduated_fee, fee_type_code: fee_type.unique_code)
        claim.case_type = case_type
      end
    end

    trait :trial do
      after(:build) do |claim|
        create(:graduated_fee_type, :grtrl)
        case_type = create(:case_type, :graduated_fee, :trial)
        claim.case_type = case_type
      end
    end

    trait :with_fixed_fee_case do
      case_type { CaseType.find_by(fee_type_code: 'FXASE') || association(:case_type, :appeal_against_sentence) }
    end

    trait :with_graduated_fee_case do
      case_type { association(:case_type, :graduated_fee) }
    end

    trait :fixed_fee do
      after(:build) do |claim|
        fee_type = create(:fixed_fee_type)
        case_type = create(:case_type, :fixed_fee, fee_type_code: fee_type.unique_code)
        claim.case_type = case_type
      end
    end

    trait :forced_validation do |claim|
      claim.force_validation { true }
    end

    trait :lgfs_scheme_9 do
      after(:create) do |claim|
        claim.defendants.each do |defendant|
          defendant
            .representation_orders
            .update_all(representation_order_date: Settings.lgfs_scheme_10_clair_release_date - 1)
        end
      end
    end

    trait :lgfs_scheme_10 do
      after(:create) do |claim|
        claim.defendants.each do |defendant|
          defendant
            .representation_orders
            .update_all(representation_order_date: Settings.lgfs_scheme_10_clair_release_date + 1)
        end
      end
    end

    trait :lgfs_scheme_11 do
      after(:create) do |claim|
        claim.defendants.each do |defendant|
          defendant
            .representation_orders
            .update_all(representation_order_date: Settings.lgfs_scheme_11_feb_2026_release_date + 1)
        end
      end
    end
  end
end
