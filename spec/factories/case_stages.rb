FactoryBot.define do
  factory :case_stage do
    case_type { association(:case_type) }
    unique_code { Faker::Lorem.unique.characters(number: 5..7, min_alpha: 1).upcase }
    sequence(:description) { |n| "Case stage #{n}" }
    sequence(:position) { |n| n }
    roles { %w[agfs lgfs] }

    trait :agfs_pre_ptph_evidence do
      description { 'Pre PTPH (evidence served)' }
      unique_code { 'PREPTPHES' }
      position { 5 }
      case_type_id { create(:case_type, :guilty_plea).id }
      roles { %w(agfs) }
    end

    trait :agfs_pre_ptph_no_evidence do
      description { 'Pre PTPH (no evidence served)' }
      unique_code { 'PREPTPH' }
      position { 10 }
      case_type_id { create(:case_type, :discontinuance).id }
      roles { %w(agfs) }
    end

    trait :cracked_trial do
      description { 'After PTPH before trial' }
      unique_code { 'AFTPTPH' }
      position { 20 }
      case_type_id { create(:case_type, :cracked_trial).id }
      roles { %w(agfs) }
    end

    trait :trial_not_concluded do
      description { 'Trial started but not concluded' }
      unique_code { 'TRLSBNC' }
      position { 30 }
      case_type_id { create(:case_type, :trial).id }
      roles { %w(agfs) }
    end

    trait :guilty_plea_not_sentenced do
      description { 'Guilty plea not yet sentenced' }
      unique_code { 'GLTNYS' }
      position { 40 }
      case_type_id { create(:case_type, :guilty_plea).id }
      roles { %w(agfs) }
    end

    trait :trial_not_sentenced do
      description { 'Trial ended not yet sentenced' }
      unique_code { 'TRLENYS' }
      position { 50 }
      case_type_id { create(:case_type, :trial).id }
      roles { %w(agfs) }
    end

    trait :retrial_not_started do
      description { 'Retrial listed but not started' }
      unique_code { 'RTRLBNS' }
      position { 60 }
      case_type_id { create(:case_type, :cracked_before_retrial).id }
      roles { %w(agfs) }
    end

    trait :retrial_not_concluded do
      description { 'Retrial started but not concluded' }
      unique_code { 'RTRSBNC' }
      position { 70 }
      case_type_id { create(:case_type, :retrial).id }
      roles { %w(agfs) }
    end

    trait :retrial_not_concluded do
      description { 'Retrial ended not yet sentenced' }
      unique_code { 'RTRENYS' }
      position { 80 }
      case_type_id { create(:case_type, :retrial).id }
      roles { %w(agfs) }
    end

    trait :pre_ptph_with_evidence do
      description { 'Pre PTPH (evidence served)' }
      unique_code { 'NOPTPHWPPE' }
      position { 90 }
      case_type_id { create(:case_type, :guilty_plea).id }
      roles { %w(lgfs) }
    end

    trait :pre_ptph_no_evidence do
      description { 'Pre PTPH (no evidence served)' }
      unique_code { 'NOPTPHNOPPE' }
      position { 100 }
      case_type_id { create(:case_type, :discontinuance).id }
      roles { %w(lgfs) }
    end

    trait :pre_ptph_or_ptph_adjourned do
      description { 'Pre PTPH or PTPH adjourned' }
      unique_code { 'PREPTPHADJ' }
      position { 110 }
      case_type_id { create(:case_type, :cracked_trial).id }
      roles { %w(lgfs) }
    end
  end
end
