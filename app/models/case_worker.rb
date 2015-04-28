class CaseWorker < ActiveRecord::Base
  ROLES = %w{ admin case_worker }

  has_one :user, as: :persona, dependent: :destroy
  has_many :case_worker_claims, dependent: :destroy
  has_many :claims, through: :case_worker_claims

  scope :admin, -> { where(role: 'admin') }
  scope :case_workers, -> { where(role: 'case_worker') }

  validates :user, presence: true
  validates :role, presence: true, inclusion: { in: ROLES }

  accepts_nested_attributes_for :user, reject_if: :all_blank

  delegate :email, to: :user

  ROLES.each do |role|
    define_method "#{role}?" do
      is?(role)
    end
  end

  def is?(role)
    self.role == role.to_s
  end
end
