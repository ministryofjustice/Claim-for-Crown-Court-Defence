class SuperAdmins::ApplicationController < ApplicationController

  before_action :authenticate_super_admin!

  private

  def authenticate_super_admin!
    unless user_signed_in? && current_user.persona.is_a?(SuperAdmin)
      redirect_to root_path_url_for_user, alert: t('requires_super_admin_authorisation')
    end
  end
end
