class MultiFirmAccountSelectionsController < ApplicationController
  skip_load_and_authorize_resource
  before_action :load_accounts

  def show; end

  def create
    selected_user = @accounts.find { |account| account.id == params.expect(:user_id).to_i }
    return authentication_failed unless selected_user

    sign_in(selected_user, event: :authentication)
    redirect_to after_sign_in_path_for(selected_user)
  end

  private

  def load_accounts
    @primary_user = User.find_by(id: session[:multi_firm_primary_user_id])
    if @primary_user&.multi_firm_user?
      @accounts = @primary_user.selectable_multi_firm_users
      authentication_failed if user_signed_in? && @accounts.exclude?(current_user)
    else
      authentication_failed
    end
  end

  def authentication_failed
    session.delete(:multi_firm_primary_user_id)
    redirect_to sign_in_path, alert: I18n.t('omniauth_callbacks.authentication_failed')
  end
end
