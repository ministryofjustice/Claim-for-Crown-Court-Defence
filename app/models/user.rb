class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ROLES = %w{ admin advocate case_worker }

  belongs_to :chamber, -> { where(role: 'advocate') }, inverse_of: :advocates
  has_many :claims_created, class_name: 'Claim', foreign_key: 'advocate_id'
  has_many :case_worker_claims, foreign_key: 'case_worker_id', dependent: :destroy
  has_many :claims_to_manage, through: :case_worker_claims, source: :claim

  scope :admin, -> { where(role: 'admin') }
  scope :advocates, -> { where(role: 'advocate') }
  scope :case_workers, -> { where(role: 'case_worker') }

  validates :role, presence: true, inclusion: { in: ROLES }

  ROLES.each do |role|
    define_method "#{role}?" do
      is?(role)
    end
  end

  def is?(role)
    self.role == role.to_s
  end
end
