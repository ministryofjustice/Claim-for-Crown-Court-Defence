class CaseWorkerClaim < ActiveRecord::Base
  belongs_to :case_worker, class_name: 'User', inverse_of: :claims_to_manage
  belongs_to :claim
end
