# == Schema Information
#
# Table name: exported_claims
#
#  id              :integer          not null, primary key
#  claim_id        :integer          not null
#  claim_uuid      :uuid             not null
#  status          :string
#  status_code     :integer
#  retries         :integer          default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#  last_request_at :datetime
#

FactoryGirl.define do
  factory :exported_claim do
    claim
    claim_uuid { claim.uuid || SecureRandom.uuid }
  end
end
