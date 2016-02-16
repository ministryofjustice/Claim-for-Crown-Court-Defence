
FactoryGirl.define do
  factory :claim, class: Claim::AdvocateClaim do

    court
    case_number { random_case_number }
    external_user
    source { 'web' }
    apply_vat  false
    # assessment    { Assessment.new }

    after(:build) do |claim|
      build(:certification, claim: claim)
      claim.fees << build(:fee, claim: claim, fee_type: FactoryGirl.build(:fee_type))
      claim.creator = claim.external_user
      populate_required_fields(claim)
    end

    after(:create) do |claim|
      defendant = create(:defendant, claim: claim)
      create(:representation_order, defendant: defendant, representation_order_date: 380.days.ago)
      claim.reload
    end

    case_type { FactoryGirl.build  :case_type }
    offence
    advocate_category 'QC'
    sequence(:cms_number) { |n| "CMS-#{Time.now.year}-#{rand(100..199)}-#{n}" }

    trait :admin_creator do
      after(:build) do |claim|
        advocate_admin = claim.external_user.provider.external_users.where(role:'admin').sample
        advocate_admin ||= create(:external_user, :admin, provider: claim.external_user.provider)
        claim.creator = advocate_admin
      end
    end

    trait :without_assessment do
      assessment  nil
    end

    factory :unpersisted_claim do
      court         { FactoryGirl.build :court }
      external_user { FactoryGirl.build :external_user, provider: FactoryGirl.build(:provider) }
      offence       { FactoryGirl.build :offence, offence_class: FactoryGirl.build(:offence_class) }
      after(:build) do |claim|
        build(:certification, claim: claim)
        claim.defendants << build(:defendant, claim: claim)
        claim.fees << build(:fee, :with_date_attended, claim: claim, fee_type: FactoryGirl.build(:fee_type))
        claim.expenses << build(:expense, :with_date_attended, claim: claim, expense_type: FactoryGirl.build(:expense_type))
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
    end

    #
    # states: initial/default state is draft
    # - alphabetical list
    #
    factory :allocated_claim do
      after(:create) { |c| publicise_errors(c) {c.submit!}; c.allocate!; }
    end

    factory :archived_pending_delete_claim do
      after(:create) { |c| c.archive_pending_delete! }
    end

    factory :authorised_claim do
      after(:create) { |c|  c.submit!; c.allocate!; set_amount_assessed(c); c.authorise! }
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

def publicise_errors(claim, &block)
  begin
    block.call
  rescue => err
    puts ">>>>>>>>>>>>>>>> DEBUG validation errors    #{__FILE__}::#{__LINE__} <<<<<<<<<<"
    ap claim
    puts claim.errors.full_messages
    claim.defendants.each do |d|
      ap d
      puts d.errors.full_messages
      d.representation_orders.each do |r|
        ap r
        puts ">>> rep order"
        puts r.errors.full_messages
      end
    end
    claim.fees.each do |f|
      ap f
      puts f.errors.full_messages
    end
    claim.expenses.each do |e|
      ap e
      puts e.errors.full_messages
    end
    raise err
  end
end

def populate_required_fields(claim)
  if claim.case_type
    if claim.case_type.requires_cracked_dates?
      claim.trial_fixed_notice_at ||= 3.months.ago
      claim.trial_fixed_at ||= 2.months.ago
      claim.trial_cracked_at ||= 1.months.ago
      claim.trial_cracked_at_third ||= 'final_third'
    end

    if claim.case_type.requires_trial_dates?
      claim.first_day_of_trial ||= 10.days.ago
      claim.trial_concluded_at ||= 8.days.ago
      claim.estimated_trial_length ||= 1
      claim.actual_trial_length ||= 2
    end

    if claim.case_type.requires_retrial_dates?
      claim.retrial_started_at ||= 5.days.ago
      claim.retrial_estimated_length ||= 1
      claim.retrial_actual_length ||= 2
      claim.retrial_concluded_at ||= 3.days.ago
    end

  end
end

# random capital letter followed by random 8 digits
def random_case_number
  ('A'..'Z').to_a.shuffle.first << rand(8**8).to_s.rjust(8,'0')
end

def set_amount_assessed(claim)
  claim.assessment.update(fees: random_amount, expenses: random_amount)
end

def random_amount
  rand(0.0..999.99).round(2)
end
