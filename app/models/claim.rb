class Claim < ActiveRecord::Base
  belongs_to :advocate
  has_many :case_worker_claims, dependent: :destroy
  has_many :case_workers, through: :case_worker_claims
  has_many :claim_fees, dependent: :destroy
  has_many :fees, through: :claim_fees
  has_many :expenses, dependent: :destroy
  has_many :defendants, dependent: :destroy

  validates :advocate, presence: true

  accepts_nested_attributes_for :claim_fees, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :defendants, reject_if: :all_blank, allow_destroy: true
end
