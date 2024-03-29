FactoryBot.define do
  factory :interim_claim, aliases: [:litigator_interim_claim], class: 'Claim::InterimClaim' do
    litigator_base_setup
    case_type { association :case_type, roles: %w[lgfs interim] }
    case_concluded_at { nil }

    transient { estimated_trial_length { 2 } }
    transient { effective_pcmh_date { 2.days.ago } }
  end

  trait :interim_trial_start_fee do
    after(:build) do |claim, options|
      claim.fees << build(:interim_fee, :trial_start, claim:)
      claim.estimated_trial_length = options.estimated_trial_length
    end
  end

  trait :interim_effective_pcmh_fee do
    after(:build) do |claim, options|
      claim.fees << build(:interim_fee, :effective_pcmh, claim:)
      claim.effective_pcmh_date = options.effective_pcmh_date
    end
  end

  trait :interim_warrant_fee do
    after(:build) do |claim|
      claim.fees << build(:interim_fee, :warrant, claim:)
    end
  end

  trait :disbursement_only_fee do
    after(:build) do |claim|
      claim.disbursements << build_list(:disbursement, 1)
      claim.fees << build(:interim_fee, :disbursement, claim:)
    end
  end
end
