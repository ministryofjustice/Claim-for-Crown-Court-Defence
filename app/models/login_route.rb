# == Schema Information
#
# Table name: login_routes
#
#  id           :integer          not null, primary key
#  login_method :string           default("legacy"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class LoginRoute < ApplicationRecord
  LEGACY = 'legacy'.freeze
  ENTRA = 'entra'.freeze
  LOGIN_METHODS = [LEGACY, ENTRA].freeze
  DEFAULT_LOGIN_METHOD = LEGACY

  belongs_to :user, foreign_key: :id, inverse_of: :login_route, optional: false

  validates :login_method, inclusion: { in: LOGIN_METHODS }
end
