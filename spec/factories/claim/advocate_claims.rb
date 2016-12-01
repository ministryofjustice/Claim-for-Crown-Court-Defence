require_relative 'claim_factory_helpers'
include ClaimFactoryHelpers


FactoryGirl.define do
  factory :claim, aliases: [:advocate_claim], class: Claim::AdvocateClaim do

    # Alias for :claim factory that should be used since we now have a litigator claim factory
    # TODO: replace all instances for create(:claim) to create(:advocate_claim)
    # factory :advocate_claim do
    # end

    form_id SecureRandom.uuid
    court
    case_number { random_case_number }
    external_user
    source { 'web' }
    apply_vat  false
    providers_ref { random_providers_ref }
    case_type { FactoryGirl.build  :case_type }
    offence
    advocate_category 'QC'
    sequence(:cms_number) { |n| "CMS-#{Time.now.year}-#{rand(100..199)}-#{n}" }

    after(:build) { |claim| post_build_actions_for_draft_claim(claim) }
    after(:create) { |claim| add_defendant_and_reporder(claim) }

    trait :admin_creator do
      after(:build) { |claim| make_claim_creator_advocate_admin(claim) }
    end

    trait :without_assessment do
      assessment  nil
    end

    trait :without_fees do
      after(:build) { |claim| make_claim_creator_advocate_admin(claim) }
    end




    factory :unpersisted_claim do
      court         { FactoryGirl.build :court }
      external_user { FactoryGirl.build :external_user, provider: FactoryGirl.build(:provider) }
      offence       { FactoryGirl.build :offence, offence_class: FactoryGirl.build(:offence_class) }
      after(:build) do |claim|
        build(:certification, claim: claim)
        claim.defendants << build(:defendant, claim: claim)
        claim.fees << build(:fixed_fee, claim: claim)
        # claim.expenses << build(:expense, :with_date_attended, claim: claim, expense_type: FactoryGirl.build(:expense_type))
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
        after(:build) do |claim|
          claim.misc_fees = []
        end
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
      after(:create) do |c|
        c.submit!
        c.case_workers << create(:case_worker)
        c.reload
        set_amount_assessed(c)
        c.authorise!
        c.archive_pending_delete!
      end
    end

    factory :authorised_claim do
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
    end
  end

end


