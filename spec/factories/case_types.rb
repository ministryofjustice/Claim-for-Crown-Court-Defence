# == Schema Information
#
# Table name: case_types
#
#  id                      :integer          not null, primary key
#  name                    :string
#  is_fixed_fee            :boolean
#  created_at              :datetime
#  updated_at              :datetime
#  requires_cracked_dates  :boolean
#  requires_trial_dates    :boolean
#  allow_pcmh_fee_type     :boolean          default(FALSE)
#  requires_maat_reference :boolean          default(FALSE)
#  requires_retrial_dates  :boolean          default(FALSE)
#  roles                   :string
#  parent_id               :integer
#  fee_type_code           :string
#

FactoryGirl.define do
  factory :case_type do
    sequence(:name)             { |n| "Case Type #{n}" }
    is_fixed_fee                false
    requires_cracked_dates      false
    requires_trial_dates        false
    requires_maat_reference     true
    roles                       %w{ agfs lgfs }

    trait :fixed_fee do
      name            'Fixed fee'
      is_fixed_fee    true
    end

    trait :requires_cracked_dates do
      requires_cracked_dates true
    end

    trait :requires_trial_dates do
      requires_trial_dates true
    end

    trait :requires_retrial_dates do
      requires_retrial_dates true
    end

    trait :contempt do
      name 'Contempt'
    end

    trait :trial do
      name 'Trial'
      requires_trial_dates true
    end

    trait :retrial do
      name 'Retrial'
      requires_trial_dates true
      requires_retrial_dates true
    end

    trait :requires_maat_reference do
      requires_maat_reference true
    end

    trait :allow_pcmh_fee_type do
      allow_pcmh_fee_type true
    end

    trait :hsts do
      name 'Hearing subsequent to sentence'
      roles [ 'lgfs' ]
    end
  end
end
