# == Schema Information
#
# Table name: case_workers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  location_id :integer
#  roles       :string
#

class CaseWorker < ActiveRecord::Base
  auto_strip_attributes squish: true, nullify: true

  ROLES = %w{ admin case_worker }

  include Roles

  belongs_to :location
  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :case_worker_claims, dependent: :destroy
  has_many :claims, class_name: Claim::BaseClaim, through: :case_worker_claims, after_remove: :unallocate!



  default_scope { includes(:user) }
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  validates :location, presence: {message: 'Location cannot be blank'}
  validates :user, presence: {message: 'User cannot be blank'}

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user

  def soft_delete
    self.transaction do
      self.user.soft_delete
      update(deleted_at: Time.zone.now)
    end
  end

  def active?
    self.deleted_at.nil?
  end

  protected

  def unallocate!(record)
    record.submit! if record.allocated? && (record.case_workers - [self]).none?
  end
end
