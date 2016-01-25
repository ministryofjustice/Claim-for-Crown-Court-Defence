class SessionsController < Devise::SessionsController
  skip_load_and_authorize_resource only: [:new, :create, :destroy]
  before_action :set_user_email, only: [:destroy]

  private

  def set_user_email
    @current_user_email = current_user.email
  end

  def respond_to_on_destroy
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name, email: @current_user_email) }
    end
  end
end
