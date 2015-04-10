class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    case resource.role
      when 'advocate'
        advocates_root_url
      when 'case_worker'
        case_workers_root_url
      when 'admin'
        admin_root_url
      else
        raise 'Invalid or missing role'
    end
  end
end
