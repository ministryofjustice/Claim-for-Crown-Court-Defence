# == Schema Information
#
# Table name: courts
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  name       :string(255)
#  court_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Court < ActiveRecord::Base
  COURT_TYPES = %w( crown magistrate )

  has_many :claims, dependent: :nullify

  validates :code, presence: true, uniqueness: { case_sensitve: false }
  validates :name, presence: true, uniqueness: { case_sensitve: false }
  validates :court_type, presence: true, inclusion: { in: COURT_TYPES }
end
