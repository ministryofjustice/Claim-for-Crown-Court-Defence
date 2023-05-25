#
# NOTE: use the :advocate_claim alias when calling this factory to
# differentiate from other claim types.
#
FactoryBot.define do
  factory :claim, aliases: [:advocate_claim, :advocate_final_claim], class: 'Claim::AdvocateClaim' do
    # NOTE: this was introduced because it was the only way to get FactoryBot to set
    # model attributes on initialize (which seems not to be the default behaviour) and
    # was causing the factory not to assign the appropriate attributes/associations on
    # initialize which makes after_initialize logic not to behave as expected since the
    # expected values are not yet set.
    # More details can be found here:
    # https://stackoverflow.com/questions/5916162/problem-with-factory-girl-association-and-after-initialize
    initialize_with { new(**attributes) }

    advocate_base_setup

    after(:build) { |claim| post_build_actions_for_draft_final_claim(claim) }

    trait :admin_creator do
      after(:build) { |claim| make_claim_creator_advocate_admin(claim) }
    end

    trait :without_assessment do
      assessment { nil }
    end

    trait :without_fees do
      after(:build) do |claim|
        make_claim_creator_advocate_admin(claim)
        claim.fees.clear
      end
    end

    trait :without_misc_fees do
      after(:build) { |claim| claim.misc_fees = [] }
    end

    trait :with_fixed_fee_case do
      case_type { CaseType.find_by(fee_type_code: 'FXASE') || association(:case_type, :appeal_against_sentence) }
    end

    trait :with_graduated_fee_case do
      case_type { association(:case_type, :graduated_fee) }
    end

    factory :unpersisted_claim do
      court         { FactoryBot.build(:court) }
      external_user { FactoryBot.build(:external_user, provider: FactoryBot.build(:provider)) }
      offence       { FactoryBot.build(:offence, offence_class: FactoryBot.build(:offence_class)) }
      after(:build) do |claim|
        certify_claim(claim)
        claim.defendants << build(:defendant, claim:)
        add_fee(:fixed_fee, claim)
      end
    end

    factory :invalid_claim do
      case_type     { nil }
    end

    factory :draft_claim do
      # do nothing as default state is draft
      # only here for iteration of all states in
      # rake task

      # NOTE: remove the certification that general build would have added
      #       as only submitted+ states need certifying
      after(:build) do |claim|
        claim.certification = nil if claim.certification
      end

      trait :without_misc_fee do
        after(:build) { |claim| claim.misc_fees = [] }
      end
    end

    #
    # states: initial/default state is draft
    # - alphabetical list
    #
    factory :allocated_claim do
      after(:create) { |claim| allocate_claim(claim); claim.reload }
    end

    # DEPRECATED see shared traits
    factory :archived_pending_delete_claim do
      after(:create) { |claim| advance_to_pending_delete(claim) }
    end

    # DEPRECATED see shared traits
    factory :authorised_claim do
      offence { association :offence, :with_fee_scheme, offence_class: association(:offence_class) }
      after(:create) { |claim| authorise_claim(claim) }
    end

    # DEPRECATED see shared traits
    factory :redetermination_claim do
      after(:create) do |claim|
        Timecop.freeze(Time.now - 3.days) { claim.submit! }
        Timecop.freeze(Time.now - 2.days) { claim.allocate! }
        Timecop.freeze(Time.now - 1.day) { assign_fees_and_expenses_for(claim); claim.authorise! }
        claim.redetermine!
      end
    end

    # DEPRECATED see shared traits
    factory :awaiting_written_reasons_claim do
      after(:create) { |claim| claim.submit!; claim.allocate!; assign_fees_and_expenses_for(claim); claim.authorise!; claim.await_written_reasons! }
    end

    # DEPRECATED see shared traits
    factory :part_authorised_claim do
      after(:create) { |claim| claim.submit!; claim.allocate!; assign_fees_and_expenses_for(claim); claim.authorise_part! }
    end

    # DEPRECATED see shared traits
    factory :refused_claim do
      after(:create) { |claim| claim.submit!; claim.allocate!; claim.refuse! }
    end

    # DEPRECATED see shared traits
    factory :rejected_claim do
      after(:create) { |claim| claim.submit!; claim.allocate!; claim.reject! }
    end

    factory :submitted_claim do
      after(:create) { |claim| publicise_errors(claim) { claim.submit! } }

      trait :with_injection do
        after(:create) do |claim|
          create(:injection_attempt, claim:)
        end
      end

      trait :with_injection_error do
        after(:create) do |claim|
          create(:injection_attempt, :with_errors, claim:)
        end
      end
    end
  end
end
