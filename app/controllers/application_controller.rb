class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user_messages_count

  load_and_authorize_resource

  def current_user_messages_count
    UserMessageStatus.for(current_user).not_marked_as_read.count
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path_url_for_user, alert: 'Unauthorised'
  end

  def root_path_url_for_user
    if current_user
      method_name = "after_sign_in_path_for_#{current_user.persona.class.to_s.downcase}"
      send(method_name)
    else
      new_user_session_url
    end
  end

  def after_sign_in_path_for(resource)
    method_name = "after_sign_in_path_for_#{current_user.persona.class.to_s.downcase}"
    send(method_name)
  end

  private

  def after_sign_in_path_for_advocate
    case current_user.persona.role
    when 'advocate'
      advocates_landing_url
    when 'admin'
      advocates_root_url
    end
  end


  def after_sign_in_path_for_caseworker
    case current_user.persona.role
    when 'case_worker'
      case_workers_root_url
    when 'admin'
      case_workers_admin_root_url
    end
  end

  def method_missing(method, *args)
    if method.to_s =~ /after_sign_in_path_for_(.*)/
      raise "Unrecognised user type #{$1}"
    end
    super
  end

end
