FactoryGirl.define do
  factory :claim do
    court
    case_number { Faker::Number.number(10) }
    advocate
    case_type 'trial'
    offence
    advocate_category 'qc_alone'
    sequence(:indictment_number) { |n| "12345-#{n}" }
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