class Claim < ActiveRecord::Base
  include Claims::StateMachine

  belongs_to :court
  belongs_to :advocate, class_name: 'User', inverse_of: :claims_created
  has_many :case_worker_claims, dependent: :destroy
  has_many :case_workers, through: :case_worker_claims
  has_many :claim_fees, dependent: :destroy, inverse_of: :claim
  has_many :fees, through: :claim_fees
  has_many :expenses, dependent: :destroy, inverse_of: :claim
  has_many :defendants, dependent: :destroy, inverse_of: :claim
  has_many :documents, dependent: :destroy, inverse_of: :claim

  validates :advocate, presence: true
  validates :court, presence: true

  accepts_nested_attributes_for :claim_fees, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :defendants, reject_if: :all_blank, allow_destroy: true
end
