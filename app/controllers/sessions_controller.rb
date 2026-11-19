class SessionsController < Devise::SessionsController
  skip_load_and_authorize_resource only: %i[new create destroy]
  prepend_before_action(only: :destroy) { DualLogin.new(session).clear }
  before_action :set_user_id, only: [:destroy]
  before_action :require_email_identification, only: %i[new create]
  helper_method :identified_password_step?

  def new
    email = identified_password_step? ? legacy_sign_in_email : params.dig(:user, :email)
    self.resource = resource_class.new(email: email)
  end

  def create
    bind_identified_email if identified_password_step?
    super { DualLogin.new(session).clear }
  end

  private

  def bind_identified_email
    credentials = params.expect(user: %i[email password remember_me]).merge(email: legacy_sign_in_email)
    params[:user] = credentials
    # Warden reads the request parameters, not the controller's strong-parameter copy.
    request.parameters[:user] = credentials.to_h
  end

  def require_email_identification
    flow = DualLogin.new(session)
    unless identified_password_step?
      flow.clear
      redirect_to dual_login_path if DualLogin.public_rollout?
      return
    end
    return if flow.allowed?(LoginRoute::LEGACY)

    flow.clear
    redirect_to sign_in_path, alert: t('session_routing.unavailable')
  end

  # Use trusted route defaults, including on Warden's failed-login recall.
  def identified_password_step?
    request.path_parameters[:standard_sign_in] != true
  end

  def legacy_sign_in_email
    DualLogin.new(session).email
  end

  def set_user_id
    @current_user_id = current_user.id
  end

  def respond_to_on_destroy(non_navigational_status: :no_content)
    respond_to do |format|
      format.all { head non_navigational_status }
      format.any(*navigational_formats) do
        redirect_to after_sign_out_path_for(resource_name, user_id: @current_user_id)
      end
    end
  end
end
