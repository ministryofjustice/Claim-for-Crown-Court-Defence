class SessionRoutingController < ApplicationController
  skip_load_and_authorize_resource only: %i[new create]

  def new
    session.delete(:legacy_sign_in_email)
    @email = params[:email].to_s
  end

  def create
    @email = params[:email].to_s.strip

    if @email.blank?
      @error = t('session_routing.new.errors.blank_email')
      return render :new, status: :unprocessable_content
    end

    unless @email.match?(URI::MailTo::EMAIL_REGEXP)
      @error = t('session_routing.new.errors.invalid_email')
      return render :new, status: :unprocessable_content
    end

    redirect_to destination_for(@email)
  end

  private

  def destination_for(email)
    case LoginRoute.method_for(email)
    when LoginRoute::ENTRA
      session.delete(:legacy_sign_in_email)
      user_entra_id_omniauth_authorize_path
    else
      session[:legacy_sign_in_email] = email
      new_user_session_path
    end
  end
end
