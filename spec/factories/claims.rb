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
#  amount_assessed        :decimal(, )
#

FactoryGirl.define do
  factory :claim do
    court
    case_number { Faker::Number.number(10) }
    advocate

    after(:build) do |claim|
      claim.creator_id = claim.advocate.id
    end

    case_type 'trial'
    offence
    advocate_category 'qc_alone'
    prosecuting_authority 'cps'
    sequence(:cms_number) { |n| "CMS-#{Time.now.year}-#{rand(100..199)}-#{n}" }

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
      after(:create) { |c| c.submit!; c.allocate!; c.pay_part!; c.reject_parts!; c.appeal! }
    end

    factory :archived_pending_delete_claim do
      after(:create) { |c| c.archive_pending_delete! }
    end

    factory :awaiting_further_info_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.pay_part!; c.await_further_info!  }
    end

    factory :awaiting_info_from_court_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.await_info_from_court!  }
    end

    factory :completed_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.pay!; c.complete!; }
    end

    factory :paid_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.pay! }
    end

    factory :part_paid_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.pay_part! }
    end

    factory :parts_rejected_claim do
      after(:create) { |c| c.submit!; c.allocate!; c.pay_part!; c.reject_parts!  }
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
