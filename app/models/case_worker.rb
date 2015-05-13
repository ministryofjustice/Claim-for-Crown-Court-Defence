class CaseWorker < ActiveRecord::Base
  ROLES = %w{ admin case_worker }
  include UserRoles

  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :case_worker_claims, dependent: :destroy
  has_many :claims, through: :case_worker_claims

  validates :user, presence: true

  accepts_nested_attributes_for :user

  delegate :email, to: :user
end
