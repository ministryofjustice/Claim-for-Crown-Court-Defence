class SessionRoutingController < ApplicationController
  skip_load_and_authorize_resource only: %i[new create]

  def new
    DualLogin.new(session).clear
    @email = params[:email].to_s
  end

  def create
    flow = DualLogin.new(session)
    flow.clear
    @email = params[:email].to_s.strip
    @error = email_error
    return render :new, status: :unprocessable_content if @error
    return redirect_to sign_in_path, alert: t('session_routing.unavailable') unless flow.identify(@email)

    redirect_to destination_for(flow.login_method)
  end

  private

  def email_error
    return t('session_routing.new.errors.blank_email') if @email.blank?

    t('session_routing.new.errors.invalid_email') unless @email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def destination_for(login_method)
    case login_method
    when LoginRoute::ENTRA
      user_entra_id_omniauth_authorize_path
    else
      new_user_session_path
    end
  end
end
