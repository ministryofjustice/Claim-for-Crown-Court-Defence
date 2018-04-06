# == Schema Information
#
# Table name: injection_attempts
#
#  id             :integer          not null, primary key
#  claim_id       :integer
#  succeeded      :boolean
#  created_at     :datetime
#  updated_at     :datetime
#  error_messages :json
#  deleted_at     :datetime
#

FactoryBot.define do
  factory :injection_attempt do
    claim
    succeeded true
    error_messages nil

    trait :with_success do
      succeeded true
      error_messages nil
    end
    
    trait :with_errors do
      succeeded false
      error_messages "{\"errors\":[ {\"error\":\"injection error 1\"},{\"error\":\"injection error 2\"}]}"
    end
  end
end

