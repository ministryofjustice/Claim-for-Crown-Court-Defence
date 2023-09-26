FactoryBot.define do
  factory :case_type do
    sequence(:name)             { |n| "Case Type #{n}" }
    is_fixed_fee                { false }
    requires_cracked_dates      { false }
    requires_trial_dates        { false }
    requires_maat_reference     { true }
    roles                       { %w[agfs lgfs] }
    uuid { SecureRandom.uuid }

    initialize_with { CaseType.find_or_create_by(name:) }

    trait :agfs_roles do
      roles { %w[agfs] }
    end

    trait :lgfs_roles do
      roles { %w[lgfs] }
    end

    trait :agfs_lgfs_roles do
      roles { %w[agfs lgfs] }
    end

    trait :all_roles do
      roles { %w[agfs lgfs interim] }
    end

    trait :fixed_fee do
      appeal_against_sentence
    end

    trait :graduated_fee do
      name { 'Graduated fee' }
      is_fixed_fee { false }
      fee_type_code { 'GRTRL' }
    end

    trait :requires_cracked_dates do
      requires_cracked_dates { true }
    end

    trait :requires_trial_dates do
      requires_trial_dates { true }
    end

    trait :requires_retrial_dates do
      requires_retrial_dates { true }
    end

    trait :elected_cases_not_proceeded do
      name { 'Elected cases not proceeded' }
      is_fixed_fee { true }
      allow_pcmh_fee_type { false }
      requires_retrial_dates { false }
      requires_maat_reference { true }
      requires_cracked_dates { false }
      requires_trial_dates { false }
      fee_type_code { 'FXENP' }
      agfs_lgfs_roles
    end

    trait :contempt do
      name { 'Contempt' }
      is_fixed_fee { true }
      allow_pcmh_fee_type { false }
      requires_retrial_dates { false }
      requires_maat_reference { true }
      requires_cracked_dates { false }
      requires_trial_dates { false }
      fee_type_code { 'FXCON' }
      agfs_lgfs_roles
    end

    trait :appeal_against_conviction do
      name { 'Appeal against conviction' }
      is_fixed_fee { true }
      allow_pcmh_fee_type { false }
      requires_retrial_dates { false }
      requires_maat_reference { true }
      requires_cracked_dates { false }
      requires_trial_dates { false }
      fee_type_code { 'FXACV' }
      agfs_lgfs_roles
    end

    trait :appeal_against_sentence do
      name { 'Appeal against sentence' }
      is_fixed_fee { true }
      allow_pcmh_fee_type { false }
      requires_retrial_dates { false }
      requires_maat_reference { true }
      requires_cracked_dates { false }
      requires_trial_dates { false }
      roles { %w[agfs lgfs] }
      fee_type_code { 'FXASE' }
    end

    trait :guilty_plea do
      name { 'Guilty plea' }
      allow_pcmh_fee_type { true }
      requires_retrial_dates { false }
      fee_type_code { 'GRGLT' }
      agfs_lgfs_roles
    end

    trait :trial do
      name { 'Trial' }
      fee_type_code { 'GRTRL' }
      allow_pcmh_fee_type { true }
      requires_trial_dates { true }
      all_roles
    end

    trait :discontinuance do
      name { 'Discontinuance' }
      fee_type_code { 'GRDIS' }
      requires_retrial_dates { false }
      allow_pcmh_fee_type { true }
      agfs_lgfs_roles
    end

    trait :retrial do
      name { 'Retrial' }
      fee_type_code { 'GRRTR' }
      allow_pcmh_fee_type { true }
      requires_trial_dates { true }
      requires_retrial_dates { true }
      all_roles
    end

    trait :cracked_trial do
      name { 'Cracked Trial' }
      fee_type_code { 'GRRAK' }
      requires_cracked_dates { true }
      allow_pcmh_fee_type { true }
      agfs_lgfs_roles
    end

    trait :cracked_before_retrial do
      name { 'Cracked before retrial' }
      fee_type_code { 'GRCBR' }
      requires_cracked_dates { true }
      allow_pcmh_fee_type { true }
      agfs_lgfs_roles
    end

    trait :requires_maat_reference do
      requires_maat_reference { true }
    end

    trait :allow_pcmh_fee_type do
      allow_pcmh_fee_type { true }
    end

    trait :hsts do
      name { 'Hearing subsequent to sentence' }
      lgfs_roles
    end

    trait :hearing_subsequent_to_sentence do
      hsts
    end

    trait :cbr do
      name { 'Breach of Crown Court order' }
      fee_type_code { 'FXCBR' }
      requires_maat_reference { false }
      is_fixed_fee { true }
      agfs_lgfs_roles
    end
  end
end
