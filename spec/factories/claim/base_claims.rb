FactoryBot.define do
  trait :advocate_base_setup do
    form_id { SecureRandom.uuid }
    court
    case_number { random_case_number }
    external_user
    source { 'web' }
    apply_vat { false }
    providers_ref { random_providers_ref }
    case_type
    offence
    advocate_category { 'QC' }
    sequence(:cms_number) { |n| "CMS-#{Time.zone.now.year}-#{rand(100..199)}-#{n}" }

    transient do
      create_defendant_and_rep_order { true }
      create_defendant_and_rep_order_for_scheme_9 { false }
      create_defendant_and_rep_order_for_scheme_10 { false }
      create_defendant_and_rep_order_for_scheme_11 { false }
      create_defendant_and_rep_order_for_scheme_12 { false }
      create_defendant_and_rep_order_for_scheme_13 { false }
    end

    after(:create) do |claim, evaluator|
      if evaluator.create_defendant_and_rep_order_for_scheme_13
        add_defendant_and_reporder(claim, scheme_date_for('scheme 13'))
      elsif evaluator.create_defendant_and_rep_order_for_scheme_12
        add_defendant_and_reporder(claim, scheme_date_for('scheme 12'))
      elsif evaluator.create_defendant_and_rep_order_for_scheme_11
        add_defendant_and_reporder(claim, scheme_date_for('scheme 11'))
      elsif evaluator.create_defendant_and_rep_order_for_scheme_10
        add_defendant_and_reporder(claim, scheme_date_for('scheme 10'))
      elsif evaluator.create_defendant_and_rep_order_for_scheme_9
        add_defendant_and_reporder(claim, DateTime.parse('2018-03-31'))
      elsif evaluator.create_defendant_and_rep_order
        add_defendant_and_reporder(claim)
      end
    end
  end

  trait :litigator_base_setup do
    court
    case_number         { random_case_number }
    creator             { create(:external_user, :litigator) }
    external_user       { creator }
    source              { 'web' }
    apply_vat           { false }
    offence             { association :offence, :miscellaneous } # only miscellaneous offences valid for LGFS
    case_type           { association :case_type }
    case_concluded_at   { 5.days.ago }
    supplier_number     { provider.lgfs_supplier_numbers.first.supplier_number }
    providers_ref       { random_providers_ref }
    disable_for_state_transition { nil }

    transient do
      create_defendant_and_rep_order { true }
      create_defendant_and_rep_order_for_scheme_9 { false }
      create_defendant_and_rep_order_for_scheme_9a { false }
      create_defendant_and_rep_order_for_scheme_10 { false }
    end

    after(:create) do |claim, evaluator|
      if evaluator.create_defendant_and_rep_order_for_scheme_9
        claim.defendants.clear
        add_defendant_and_reporder(claim, DateTime.parse('2016-04-01'))
      elsif evaluator.create_defendant_and_rep_order_for_scheme_9a
        claim.defendants.clear
        add_defendant_and_reporder(claim, DateTime.parse('2020-09-17'))
        claim.main_hearing_date = Date.parse('2022-10-31')
      elsif evaluator.create_defendant_and_rep_order_for_scheme_10
        claim.defendants.clear
        add_defendant_and_reporder(claim, Settings.lgfs_scheme_10_clair_release_date)
      end

      if claim.defendants.blank? && evaluator.create_defendant_and_rep_order
        defendant = create(:defendant, claim:)
        create(:representation_order, defendant:, representation_order_date: 380.days.ago)
        claim.reload
      end
    end
  end
end

def publicise_errors(claim)
  yield
rescue StandardError => e
  puts "***************** DEBUG validation errors #{__FILE__}::#{__LINE__} **********"
  show_errors_of([claim]) do |c|
    show_errors_of(c.defendants) { |defendant| show_errors_of(defendant.representation_orders) }
    show_errors_of(c.fees)
    show_errors_of(c.expenses)
  end
  raise e
end

def show_errors_of(attributes)
  attributes.each do |attribute|
    ap attribute
    puts attribute.errors.full_messages
    yield(attribute) if block_given?
  end
end

def populate_required_fields(claim)
  return unless claim.case_type
  populate_cracked_dates(claim) if claim.case_type.requires_cracked_dates?
  populate_trial_dates(claim) if claim.case_type.requires_trial_dates?
  populate_retrial_dates(claim) if claim.case_type.requires_retrial_dates?
end

def populate_cracked_dates(claim)
  claim.trial_fixed_notice_at ||= 3.months.ago
  claim.trial_cracked_at ||= 2.months.ago
  claim.trial_fixed_at ||= 1.month.ago
  claim.trial_cracked_at_third ||= 'final_third'
end

def populate_trial_dates(claim)
  claim.first_day_of_trial ||= 10.days.ago
  claim.trial_concluded_at ||= 8.days.ago
  claim.estimated_trial_length ||= 1
  claim.actual_trial_length ||= 2
end

def populate_retrial_dates(claim)
  claim.retrial_started_at ||= 5.days.ago
  claim.retrial_estimated_length ||= 1
  claim.retrial_actual_length ||= 2
  claim.retrial_concluded_at ||= 3.days.ago
end

def random_case_number
  [%w[A S T].sample, rand(1990..2016), rand(1000..9999)].join
end

def assign_fees_and_expenses_for(claim)
  claim.assessment.update!(fees: random_amount, expenses: random_amount)
end

def random_amount
  rand(0.0..999.99).round(2)
end

def random_providers_ref
  SecureRandom.uuid[3..10].upcase
end

def frozen_time(&)
  Timecop.freeze(Time.new(2016, 3, 10, 11, 44, 55).utc, &)
end
