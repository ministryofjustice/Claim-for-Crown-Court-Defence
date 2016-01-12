class ExternalUsers::ApplicationController < ApplicationController
	layout 'external_users'
  before_action :authenticate_external_user!

  private

  def authenticate_external_user!
    unless user_signed_in? && current_user.persona.is_a?(ExternalUser)
      redirect_to root_path_url_for_user, alert: 'Must be signed in as an external user'
    end
  end
end
