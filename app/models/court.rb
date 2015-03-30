class Court < ActiveRecord::Base
  has_many :claims, dependent: :nullify

  validates :code, presence: true, uniqueness: { case_sensitve: false }
  validates :name, presence: true, uniqueness: { case_sensitve: false }
end
