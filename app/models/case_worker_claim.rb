# == Schema Information
#
# Table name: case_worker_claims
#
#  id             :integer          not null, primary key
#  case_worker_id :integer
#  claim_id       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class CaseWorkerClaim < ActiveRecord::Base
  belongs_to :case_worker
  belongs_to :claim
end
