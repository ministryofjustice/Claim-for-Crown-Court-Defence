class Claim < ActiveRecord::Base
  belongs_to :advocate
  has_many :case_worker_claims, dependent: :destroy
  has_many :case_workers, through: :case_worker_claims
  has_many :claim_fees, dependent: :destroy
  has_many :fees, through: :claim_fees

  validates :advocate, presence: true

  accepts_nested_attributes_for :fees, reject_if: :all_blank, allow_destroy: true
end
