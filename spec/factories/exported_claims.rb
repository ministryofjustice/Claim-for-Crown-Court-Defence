# == Schema Information
#
# Table name: exported_claims
#
#  id           :integer          not null, primary key
#  claim_id     :integer          not null
#  claim_uuid   :uuid             not null
#  status       :string
#  status_code  :integer
#  status_msg   :string
#  retries      :integer          default(0), not null
#  created_at   :datetime
#  updated_at   :datetime
#  published_at :datetime
#  retried_at   :datetime
#

FactoryGirl.define do
  factory :exported_claim do
    claim
    claim_uuid { claim.uuid || SecureRandom.uuid }

    trait :enqueued do
      status 'enqueued'
    end

    trait :published do
      status 'published'
    end
  end
end
