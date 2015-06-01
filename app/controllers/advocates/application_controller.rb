class Advocates::ApplicationController < ApplicationController
  load_and_authorize_resource
	layout 'advocate'

  private

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: t('requires_advocate_authorisation')
  end
end
