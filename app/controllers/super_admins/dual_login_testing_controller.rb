module SuperAdmins
  class DualLoginTestingController < ApplicationController
    skip_load_and_authorize_resource
    before_action :authorize_testing

    def index
      @email = params[:email].to_s.strip.downcase
      @account = User.includes(:login_route).find_by(email: @email) if @email.present?
    end

    def update
      account = User.find(params.expect(:id))
      value = params.require(:dual_login_tester)
      raise ActionController::BadRequest, 'Invalid tester approval' unless %w[true false].include?(value)

      update_route(account, 'approval', dual_login_tester: value == 'true')
      redirect_to super_admins_dual_login_testing_index_path(email: account.email)
    end

    def update_login_method
      account = User.find(params.expect(:id))
      value = params.expect(:login_method)
      raise ActionController::BadRequest, 'Invalid login method' unless LoginRoute::LOGIN_METHODS.include?(value)

      update_route(account, 'login_method', login_method: value)
      redirect_to super_admins_dual_login_testing_index_path(email: account.email)
    end

    private

    def authorize_testing
      authorize! action_name.to_sym, :dual_login_testing
    end

    def update_route(account, change, attributes)
      route = account.login_route
      if route.nil?
        flash[:alert] = t('super_admins.dual_login_testing.missing_route')
      elsif route.update(attributes)
        audit_change(account, attributes)
        flash[:notice] = t("super_admins.dual_login_testing.#{change}_updated")
      else
        flash[:alert] = t("super_admins.dual_login_testing.#{change}_failed",
                          errors: route.errors.full_messages.to_sentence)
      end
    end

    def audit_change(account, attributes)
      Rails.logger.info({ event: 'dual_login_route_updated', admin_user_id: current_user.id,
                          target_user_id: account.id, changes: attributes }.to_json)
    end
  end
end
