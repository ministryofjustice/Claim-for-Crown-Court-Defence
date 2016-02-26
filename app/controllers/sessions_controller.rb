class SessionsController < Devise::SessionsController
  skip_load_and_authorize_resource only: [:new, :create, :destroy]
  before_action :set_user_id, only: [:destroy]

  private

  def set_user_id
    @current_user_id = current_user.id
  end

  def respond_to_on_destroy
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name, user_id: @current_user_id), notice: 'You have signed out' }
    end
  end
end
