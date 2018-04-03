require_relative 'claim_factory_helpers'
include ClaimFactoryHelpers

FactoryBot.define do
  factory :claim, aliases: [:advocate_claim], class: Claim::AdvocateClaim do

    # Alias for :claim factory that should be used since we now have a litigator claim factory
    # TODO: replace all instances for create(:claim) to create(:advocate_claim)
    # factory :advocate_claim do
    # end

    # NOTE: this was introduced here because was the only way to get FactoryBot to set
    # model attributes on initialize (which seems not to be the default behaviour) and
    # was causing the factory not to assign the appropriate attributes/associations on
    # initialize which makes after_initialize logic not to behave as expected since the
    # expected values are not yet set.
    # More details can be found here:
    # https://stackoverflow.com/questions/5916162/problem-with-factory-girl-association-and-after-initialize
    initialize_with { new(attributes) }
    transient do
      create_defendant_and_rep_order true
    end

    form_id SecureRandom.uuid
    court
    case_number { random_case_number }
    external_user
    source { 'web' }
    apply_vat false
    providers_ref { random_providers_ref }
    case_type
    offence
    advocate_category 'QC'
    sequence(:cms_number) { |n| "CMS-#{Time.now.year}-#{rand(100..199)}-#{n}" }

    after(:build) { |claim| post_build_actions_for_draft_claim(claim) }
    after(:create) { |claim, evaluator| add_defendant_and_reporder(claim) if evaluator.create_defendant_and_rep_order }

    trait :admin_creator do
      after(:build) { |claim| make_claim_creator_advocate_admin(claim) }
    end

    trait :without_assessment do
      assessment nil
    end

    trait :without_fees do
      after(:build) do |claim|
        make_claim_creator_advocate_admin(claim)
        claim.fees.clear
      end
    end

    factory :unpersisted_claim do
      court         { FactoryBot.build :court }
      external_user { FactoryBot.build :external_user, provider: FactoryBot.build(:provider) }
      offence       { FactoryBot.build :offence, offence_class: FactoryBot.build(:offence_class) }
      after(:build) do |claim|
        certify_claim(claim)
        claim.defendants << build(:defendant, claim: claim)
        add_fee(:fixed_fee, claim)
      end
    end

    factory :invalid_claim do
      case_type     nil
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
      after(:create) { |c| allocate_claim(c); c.reload }
    end

    factory :archived_pending_delete_claim do
      after(:create) { |c| advance_to_pending_delete(c) }
    end

    factory :authorised_claim do
      offence { create :offence, :with_fee_scheme, offence_class: create(:offence_class) }
      after(:create) { |c| authorise_claim(c) }
    end

    factory :redetermination_claim do
      after(:create) do |c|
        Timecop.freeze(Time.now - 3.day) { c.submit! }
        Timecop.freeze(Time.now - 2.day) { c.allocate! }
        Timecop.freeze(Time.now - 1.day) { set_amount_assessed(c); c.authorise! }
        c.redetermine!
      end
    end

    factory :awaiting_written_reasons_claim do
      after(:create) { |c|  c.submit!; c.allocate!; set_amount_assessed(c); c.authorise!; c.await_written_reasons! }
    end

    factory :part_authorised_claim do
      after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.authorise_part! }
    end

    factory :refused_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.refuse! }
    end

    factory :rejected_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.reject! }
    end

    factory :submitted_claim do
      after(:create) { |c| publicise_errors(c) { c.submit! } }

      trait :with_injection do
        after(:create) do |claim|
          create(:injection_attempt, claim: claim)
        end
      end

      trait :with_injection_error do
        after(:create) do |claim|
          create(:injection_attempt, :with_errors, claim: claim)
        end
      end
    end
  end
end
