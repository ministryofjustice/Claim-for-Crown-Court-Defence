# Store of traits that can be used with any claim type
#
FactoryBot.define do
  trait :draft do
    # NOTE: remove the certification that general build would have added
    # as only submitted+ states need certifying
    after(:build) do |claim|
      claim.certification = nil if claim.certification
    end
  end

  trait :submitted do
    after(:create, &:submit!)
  end

  trait :allocated do
    after(:create) { |claim| allocate_claim(claim) }
  end

  trait :authorised do
    offence { association :offence, :with_fee_scheme, offence_class: association(:offence_class) }
    after(:create) { |claim| authorise_claim(claim) }
  end

  trait :part_authorised do
    offence { association :offence, :with_fee_scheme, offence_class: create(:offence_class) }
    after(:create) do |claim|
      allocate_claim(claim)
      claim.reload
      assign_fees_and_expenses_for(claim)
      claim.authorise_part({ author_id: claim.case_workers.first.user.id })
    end
  end

  trait :refused do
    after(:create) do |claim|
      allocate_claim(claim)
      claim.refuse!({ author_id: claim.case_workers.first.user.id })
    end
  end

  trait :rejected do
    after(:create) do |claim|
      allocate_claim(claim)
      claim.reject!({ author_id: claim.case_workers.first.user.id })
    end
  end

  trait :awaiting_written_reasons do
    after(:create) do |claim|
      authorise_claim(claim)
      claim.await_written_reasons!({ author_id: claim.external_user.user.id })
    end
  end

  trait :redetermination do
    after(:create) do |claim|
      travel_to(3.days.ago) { claim.submit! }
      travel_to(2.days.ago) { claim.allocate! }
      travel_to(1.day.ago) do
        assign_fees_and_expenses_for(claim)
        claim.authorise!
      end
      claim.redetermine!({ author_id: claim.external_user.user.id })
    end
  end

  trait :archived_pending_delete do
    after(:create) do |claim|
      authorise_claim(claim)
      claim.archive_pending_delete!
    end
  end

  trait :archived_pending_review do
    after(:create) do |claim|
      authorise_claim(claim)
      claim.archive_pending_review!
    end
  end
end
