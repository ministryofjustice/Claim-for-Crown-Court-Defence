class CaseStage < ApplicationRecord
  ROLES = %w[lgfs agfs].freeze
  include Roles

  belongs_to :case_type

  delegate_missing_to :case_type

  validates :case_type_id, presence: true
  validates :unique_code, presence: true
  validates :unique_code, uniqueness: true
  validates :description, presence: true

  scope :chronological, -> { order(position: :asc) }
  scope :active, -> { where.not("unique_code LIKE 'OBSOLETE%'") }
end
