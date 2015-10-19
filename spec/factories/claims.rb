# == Schema Information
#
# Table name: claims
#
#  id                       :integer          not null, primary key
#  additional_information   :text
#  apply_vat                :boolean
#  state                    :string
#  last_submitted_at        :datetime
#  case_number              :string
#  advocate_category        :string
#  indictment_number        :string
#  first_day_of_trial       :date
#  estimated_trial_length   :integer          default(0)
#  actual_trial_length      :integer          default(0)
#  fees_total               :decimal(, )      default(0.0)
#  expenses_total           :decimal(, )      default(0.0)
#  total                    :decimal(, )      default(0.0)
#  advocate_id              :integer
#  court_id                 :integer
#  offence_id               :integer
#  scheme_id                :integer
#  created_at               :datetime
#  updated_at               :datetime
#  valid_until              :datetime
#  cms_number               :string
#  authorised_at            :datetime
#  creator_id               :integer
#  evidence_notes           :text
#  evidence_checklist_ids   :string
#  trial_concluded_at       :date
#  trial_fixed_notice_at    :date
#  trial_fixed_at           :date
#  trial_cracked_at         :date
#  trial_cracked_at_third   :string
#  source                   :string
#  vat_amount               :decimal(, )      default(0.0)
#  uuid                     :uuid
#  case_type_id             :integer
#  form_id                  :string
#  original_submission_date :datetime
#

FactoryGirl.define do
  factory :claim do
    court
    scheme      { random_scheme }
    case_number { random_case_number }
    advocate
    source { 'web' }
    apply_vat  false
    assessment    { Assessment.new }
    after(:build) do |claim|
      claim.fees << build(:fee, claim: claim, fee_type: FactoryGirl.build(:fee_type))
      claim.creator = claim.advocate
      populate_required_fields(claim)
    end

    case_type { FactoryGirl.build  :case_type }
    offence
    advocate_category 'QC'
    sequence(:cms_number) { |n| "CMS-#{Time.now.year}-#{rand(100..199)}-#{n}" }

    after(:create) do |claim|
      defendant = create(:defendant, claim: claim)
      create(:representation_order, defendant: defendant, representation_order_date: 380.days.ago)
      claim.scheme.start_date = Date.parse('31/12/2011')
      claim.scheme.end_date = nil
      claim.reload
    end

    trait :admin_creator do
      after(:build) do |claim|
        advocate_admin = claim.advocate.chamber.advocates.where(role:'admin').sample
        advocate_admin ||= create(:advocate, :admin, chamber: claim.advocate.chamber)
        claim.creator = advocate_admin
      end
    end

    trait :without_assessment do
      assessment  nil
    end

    factory :unpersisted_claim do
      court         { FactoryGirl.build :court }
      advocate      { FactoryGirl.build :advocate, chamber: FactoryGirl.build(:chamber) }
      offence       { FactoryGirl.build :offence, offence_class: FactoryGirl.build(:offence_class) }
      after(:build) do |claim|
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
    end

    #
    # states: initial/default state is draft
    # - alphabetical list
    #
    factory :allocated_claim do
      after(:create) { |c|  publicise_errors(c) {c.submit!}; c.allocate!; }
    end

    factory :archived_pending_delete_claim do
      after(:create) { |c|
        c.archive_pending_delete! }
    end

    factory :authorised_claim do
      after(:create) { |c|  c.submit!; c.allocate!; set_amount_assessed(c); c.authorise! }
    end

    factory :redetermination_claim do
      after(:create) { |c|  c.submit!; c.allocate!; set_amount_assessed(c); c.authorise!; c.redetermine! }
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
    puts claim.errors._full_messages
    claim.defendants.each do |d|
      ap d
      puts d.errors._full_messages
      d.representation_orders.each do |r|
        ap r
        puts ">>> rep order"
        puts r.errors._full_messages
      end
    end
    claim.fees.each do |f|
      ap f
      puts f.errors._full_messages
    end
    claim.expenses.each do |e|
      ap e
      puts e.errors._full_messages
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
    elsif claim.case_type.requires_trial_dates?
      claim.first_day_of_trial ||= 10.days.ago
      claim.trial_concluded_at ||= 9.days.ago
      claim.estimated_trial_length ||= 1
      claim.actual_trial_length ||= 2
    end
  end
end

def random_scheme
  Scheme.all.sample || FactoryGirl.create(:older_scheme)
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
