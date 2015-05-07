class CaseWorker < ActiveRecord::Base
  ROLES = %w{ admin case_worker }
  include UserRoles
  include Authenticatable

  has_many :case_worker_claims, dependent: :destroy
  has_many :claims, through: :case_worker_claims
end
