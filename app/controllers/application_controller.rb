class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    case current_user.persona_type
      when 'Advocate'
        case current_user.persona.role
          when 'advocate'
            advocates_root_url
          when 'admin'
            advocates_admin_root_url
        end
      when 'CaseWorker'
        case current_user.persona.role
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
