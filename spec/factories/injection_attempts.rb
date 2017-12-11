# == Schema Information
#
# Table name: injection_attempts
#
#  id            :integer          not null, primary key
#  claim_id      :integer
#  succeeded     :boolean
#  error_message :string
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryBot.define do
  factory :injection_attempt do
    claim
    succeeded true
    error_message nil
  end
end

