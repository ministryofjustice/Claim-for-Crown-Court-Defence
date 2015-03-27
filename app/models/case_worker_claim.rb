class CaseWorkerClaim < ActiveRecord::Base
  belongs_to :case_worker, class_name: 'User', inverse_of: :case_workers
  belongs_to :claim
end
