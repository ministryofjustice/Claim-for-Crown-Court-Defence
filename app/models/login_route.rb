class LoginRoute < ApplicationRecord
  belongs_to :user, foreign_key: :id, inverse_of: :login_route, optional: false

  validates :login_method, inclusion: { in: %w[legacy entra] }
end
