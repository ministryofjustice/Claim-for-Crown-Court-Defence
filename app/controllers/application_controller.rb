class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    case current_user.rolable_type
      when 'Advocate'
        advocates_root_url
      when 'CaseWorker'
        case current_user.rolable.role
          when 'case_worker'
            case_workers_root_url
          when 'admin'
            case_workers_admin_root_url
        end
      else
        raise 'Invalid or missing role'
    end
  end
end
