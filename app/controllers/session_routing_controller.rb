class SessionRoutingController < ApplicationController
  skip_load_and_authorize_resource only: %i[new create]

  def new
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
      user_entra_id_omniauth_authorize_path
    else
      new_user_session_path(email:)
    end
  end
end
