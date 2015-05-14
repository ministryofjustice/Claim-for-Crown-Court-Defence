class Advocate < ActiveRecord::Base
  ROLES = %w{ admin advocate }
  include UserRoles

  belongs_to :chamber
  has_many :claims, dependent: :destroy

  default_scope { includes(:user) }

  validates :user, presence: true
  validates :chamber, :first_name, :last_name, presence: true

  def name
    [first_name, last_name] * ' '
  end
end
