class SessionsController < Devise::SessionsController
  skip_load_and_authorize_resource only: %i[new create destroy]
  before_action :set_user_id, only: [:destroy]
  before_action :require_email_identification, only: %i[new create]

  def new
    self.resource = resource_class.new(email: legacy_sign_in_email)
  end

  def create
    params.expect(user: %i[email password remember_me])[:email] = legacy_sign_in_email
    super
  end

  private

  def require_email_identification
    return if legacy_sign_in_email.present?

    redirect_to sign_in_path
  end

  def legacy_sign_in_email
    session[:legacy_sign_in_email]
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
