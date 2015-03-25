class CaseWorkerClaim < ActiveRecord::Base
  belongs_to :case_worker
  belongs_to :claim
end
