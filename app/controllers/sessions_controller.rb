class SessionsController < Devise::SessionsController
  skip_load_and_authorize_resource only: %i[new create destroy]
  before_action :set_user_id, only: [:destroy]

  private

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
