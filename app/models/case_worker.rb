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
#

class CaseWorker < ActiveRecord::Base
  auto_strip_attributes squish: true, nullify: true

  ROLES = %w{ admin case_worker }

  include Roles
  include SoftlyDeletable

  belongs_to :location
  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :case_worker_claims
  has_many :claims, -> { active }, class_name: Claim::BaseClaim, through: :case_worker_claims, after_remove: :unallocate!



  default_scope { includes(:user) }

  validates :location, presence: {message: 'Location cannot be blank'}
  validates :user, presence: {message: 'User cannot be blank'}

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user

  def before_soft_delete
    self.user.soft_delete
  end

  protected

  def unallocate!(record)
    record.submit! if record.allocated? && (record.case_workers - [self]).none?
  end
end
