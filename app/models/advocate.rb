class Advocate < ActiveRecord::Base
  ROLES = %w{ admin advocate }
  include UserRoles
  include Authenticatable

  belongs_to :chamber
  has_many :claims, dependent: :destroy

  validates :first_name, :last_name, presence: true

  def name
    [first_name, last_name] * ' '
  end
end
