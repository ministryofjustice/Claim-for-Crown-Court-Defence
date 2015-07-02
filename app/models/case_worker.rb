# == Schema Information
#
# Table name: case_workers
#
#  id         :integer          not null, primary key
#  role       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class CaseWorker < ActiveRecord::Base
  ROLES = %w{ admin case_worker }
  include UserRoles

  belongs_to :location
  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :case_worker_claims, dependent: :destroy
  has_many :claims, through: :case_worker_claims, after_remove: :unallocate!

  default_scope { includes(:user) }

  validates :location, presence: true
  validates :user, presence: true

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user

  protected

  def unallocate!(record)
    record.submit! if record.allocated? && (record.case_workers - [self]).none?
  end
end
