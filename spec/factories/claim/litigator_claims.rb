FactoryGirl.define do
  factory :litigator_claim, class: Claim::LitigatorClaim do

    court
    case_number         { random_case_number }
    creator             { build :external_user, :litigator }
    external_user       { creator }
    source              { 'web' }
    apply_vat           false
    offence             { create(:offence, :miscellaneous) } #only miscellaneous offences valid for LGFS
    case_type           { create(:case_type) }
    case_concluded_at   { 5.days.ago }

    after(:build) do |claim|
      claim.fees << build(:misc_fee, claim: claim) # fees required for valid claims
    end

    factory :unpersisted_litigator_claim do
      court         { build :court }
      external_user { creator }
      creator       { build :external_user, :litigator, provider: build(:provider, :lgfs) }
      offence       { build :offence, offence_class: build(:offence_class) }
    end

    trait :draft do
      # do nothing as default state is draft
      # only here for iteration of all states in
      # rake task
    end

    #
    # states: initial/default state is draft
    # - alphabetical list
    #
    trait :allocated do
      after(:create) { |c| c.submit!; c.allocate!; }
    end

    trait :archived_pending_delete do
      after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.authorise!; c.archive_pending_delete! }
    end

    trait :authorised do
      after(:create) { |c|  c.submit!; c.allocate!; set_amount_assessed(c); c.authorise! }
    end

    trait :part_authorised do
      after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.authorise_part! }
    end

    trait :refused do
      after(:create) { |c| c.submit!; c.allocate!; c.refuse! }
    end

    trait :rejected do
      after(:create) { |c| c.submit!; c.allocate!; c.reject! }
    end

    trait :submitted do
      after(:create) { |c| c.submit! }
    end

  end
end

