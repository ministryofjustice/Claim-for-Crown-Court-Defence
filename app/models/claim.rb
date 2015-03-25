class Claim < ActiveRecord::Base
  belongs_to :advocate
  has_many :case_worker_claims, dependent: :destroy
  has_many :case_workers, through: :case_worker_claims

  validates :advocate, presence: true
end
