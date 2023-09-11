# == Schema Information
#
# Table name: case_workers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  location_id :integer
#  roles       :string
#  deleted_at  :datetime
#  uuid        :uuid
#

class CaseWorker < ApplicationRecord
  auto_strip_attributes squish: true, nullify: true

  ROLES = %w[admin case_worker provider_management].freeze

  include Roles
  include SoftlyDeletable

  belongs_to :location
  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :case_worker_claims
  has_many :claims, -> { active },
           class_name: 'Claim::BaseClaim',
           through: :case_worker_claims,
           after_remove: :unallocate!

  default_scope { includes(:user) }

  validates :location, presence: true
  validates :user, presence: true

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user

  def before_soft_delete
    user.soft_delete
  end

  def message_claim_path
    'case_workers_claim_path'
  end

  protected

  def unallocate!(record)
    record.submit! if record.allocated? && (record.case_workers - [self]).none?
  end
end
