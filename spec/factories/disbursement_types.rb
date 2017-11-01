# == Schema Information
#
# Table name: disbursement_types
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime
#  updated_at  :datetime
#  deleted_at  :datetime
#  unique_code :string
#

FactoryBot.define do
  factory :disbursement_type do
    sequence(:name) { |n| "#{random_description} - #{n}" }
    sequence(:unique_code) { |n| "XX#{n}" }

    trait :forensic do
      name 'Forensic scientists'
      unique_code 'FOR'
    end
  end
end

def random_description
  disbursement_descriptions.sample
end

def disbursement_descriptions
  [
    'Accident reconstruction report',
    'Accounts',
    'Computer experts',
    'Consultant medical reports',
    'Costs judge application fee',
    'Costs judge preparation award',
    'DNA testing',
    'Engineer',
    'Enquiry agents',
    'Facial mapping expert',
    'Financial expert',
    'Fingerprint expert',
    'Fire assessor/explosives expert',
    'Forensic scientists',
    'Handwriting expert',
    'Interpreter',
    'Lip readers',
    'Medical expert',
    'Memorandum of conviction fee',
    'Meteorologist',
    'Other',
    'Overnight expenses',
    'Pathologist',
    'Photocopying',
    'Psychiatric reports',
    'Psychological report',
    'Surveyor/architect',
    'Transcripts',
    'Translator',
    'Travel costs',
    'Vet report',
    'Voice recognition'
  ]
end
