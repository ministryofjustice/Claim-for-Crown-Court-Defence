# == Schema Information
#
# Table name: claims
#
#  id                     :integer          not null, primary key
#  additional_information :text
#  apply_vat              :boolean
#  state                  :string(255)
#  case_type              :string(255)
#  submitted_at           :datetime
#  case_number            :string(255)
#  advocate_category      :string(255)
#  prosecuting_authority  :string(255)
#  indictment_number      :string(255)
#  first_day_of_trial     :date
#  estimated_trial_length :integer          default(0)
#  actual_trial_length    :integer          default(0)
#  fees_total             :decimal(, )      default(0.0)
#  expenses_total         :decimal(, )      default(0.0)
#  total                  :decimal(, )      default(0.0)
#  advocate_id            :integer
#  court_id               :integer
#  offence_id             :integer
#  scheme_id              :integer
#  created_at             :datetime
#  updated_at             :datetime
#  valid_until            :datetime
#  cms_number             :string(255)
#  paid_at                :datetime
#  creator_id             :integer
#  amount_assessed        :decimal(, )      default(0.0)
#  notes                  :text
#  evidence_notes         :string(255)
#  evidence_checklist_ids :string(255)
#

FactoryGirl.define do
  factory :claim do

    court
    case_number { Faker::Number.number(10) }
    advocate
    after(:build) do |claim|
      claim.creator = claim.advocate
    end

    case_type 'trial'
    offence
    advocate_category 'QC'
    prosecuting_authority 'cps'
    sequence(:cms_number) { |n| "CMS-#{Time.now.year}-#{rand(100..199)}-#{n}" }

    trait :admin_creator do
      after(:build) do |claim|
        advocate_admin = claim.advocate.chamber.advocates.where(role:'admin').sample
        advocate_admin ||= create(:advocate, :admin, chamber: claim.advocate.chamber)
        claim.creator = advocate_admin
      end
    end

    factory :unpersisted_claim do
      court         { FactoryGirl.build :court }
      advocate      { FactoryGirl.build :advocate, chamber: FactoryGirl.build(:chamber) }
      offence       { FactoryGirl.build :offence, offence_class: FactoryGirl.build(:offence_class) }
    end

    factory :invalid_claim do
      case_type 'invalid case type'
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
      after(:create) { |c| c.submit!; c.allocate!; }
    end

    factory :appealed_claim do
      after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.pay_part!; c.reject_parts!; c.appeal! }
    end

    factory :archived_pending_delete_claim do
      after(:create) { |c| c.archive_pending_delete! }
    end

    factory :awaiting_further_info_claim do
      after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.pay_part!; c.await_further_info!  }
    end

    factory :awaiting_info_from_court_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.await_info_from_court!  }
    end

    factory :completed_claim do
      after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.pay!; c.complete!; }
    end

    factory :paid_claim do
      after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.pay! }
    end

    factory :part_paid_claim do
      after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.pay_part! }
    end

    factory :parts_rejected_claim do
      after(:create) { |c| c.submit!; c.allocate!; set_amount_assessed(c); c.pay_part!; c.reject_parts!  }
    end

    factory :refused_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.refuse! }
    end

    factory :rejected_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.reject! }
    end

    factory :submitted_claim do
      after(:create) { |c| c.submit! }
    end

  end

end


def set_amount_assessed(claim)
  claim.update_attribute(:amount_assessed, rand(0.0..999.99).round(2))
end
