# == Schema Information
#
# Table name: document_type_claims
#
#  id               :integer          not null, primary key
#  claim_id         :integer          not null
#  document_type_id :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryBot.define do
  factory :document_type_claim do
    claim
    document_type
  end
end
