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

  # Unknown addresses fall back to the legacy method so that the email-only step
  # does not reveal whether an account exists.
  def self.method_for(email)
    normalised = email.to_s.strip.downcase
    return DEFAULT_LOGIN_METHOD if normalised.blank?

    User.find_by(email: normalised)&.login_route&.login_method || DEFAULT_LOGIN_METHOD
  end
end
