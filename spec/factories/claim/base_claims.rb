require 'timecop'

FactoryGirl.define do

  trait :litigator_base_setup do
    court
    case_number         { random_case_number }
    creator             { build :external_user, :litigator }
    external_user       { creator }
    source              { 'web' }
    apply_vat           false
    offence             { create(:offence, :miscellaneous) } #only miscellaneous offences valid for LGFS
    case_type           { create(:case_type) }
    case_concluded_at   { 5.days.ago }
    supplier_number     { provider.lgfs_supplier_numbers.first.supplier_number }
    providers_ref       { random_providers_ref }

    after(:create) do |claim|
      defendant = create(:defendant, claim: claim)
      create(:representation_order, defendant: defendant, representation_order_date: 380.days.ago)
      claim.reload
    end
  end
end

#
# These methods are going to the global namespace so do not abuse it and check for collisions
#

def claim_state_common_traits
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
    # after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.authorise!; c.archive_pending_delete! }
    after(:create) do |c|
      c.submit!
      c.case_workers << create(:case_worker)
      c.reload
      set_amount_assessed(c)
      c.authorise!
      c.archive_pending_delete!
    end
  end

  trait :authorised do
    after(:create) { |c|  c.submit!; c.allocate!; set_amount_assessed(c); c.authorise! }
  end

  trait :awaiting_written_reasons do
    after(:create) { |c|  c.submit!; c.allocate!; set_amount_assessed(c); c.authorise!; c.await_written_reasons! }
  end

  trait :part_authorised do
    after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.authorise_part! }
  end

  trait :redetermination do
    after(:create) do |c|
      Timecop.freeze(Time.now - 3.day) { c.submit! }
      Timecop.freeze(Time.now - 2.day) { c.allocate! }
      Timecop.freeze(Time.now - 1.day) { set_amount_assessed(c); c.authorise! }
      c.redetermine!
    end
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

def publicise_errors(claim, &block)
  begin
    block.call
  rescue => err
    puts "***************** DEBUG validation errors    #{__FILE__}::#{__LINE__} **********"
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
  ('A'..'Z').to_a.sample << rand(8**8).to_s.rjust(8,'0')
end

def set_amount_assessed(claim)
  claim.assessment.update(fees: random_amount, expenses: random_amount)
end

def random_amount
  rand(0.0..999.99).round(2)
end

def random_providers_ref
  SecureRandom.uuid[3..10].upcase
end

def frozen_time
  Timecop.freeze(Time.new(2016, 3, 10, 11, 44, 55).utc) { yield }
end
