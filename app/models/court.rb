class Court < ActiveRecord::Base
  COURT_TYPES = %w( crown magistrate )

  has_many :claims, dependent: :nullify

  validates :code, presence: true, uniqueness: { case_sensitve: false }
  validates :name, presence: true, uniqueness: { case_sensitve: false }
  validates :court_type, presence: true, inclusion: { in: COURT_TYPES }
end
