module ExternalUsers
  module Admin
    class ExternalUsersController < ExternalUsers::Admin::ApplicationController
      include PasswordHelpers
      include UserAdminHelpers

      ATTRIBUTES = %i[id email email_confirmation password password_confirmation
                      current_password first_name last_name email_notification_of_message].freeze

      before_action :set_external_user, only: %i[show edit update destroy change_password update_password]

      def index
        @external_users = current_provider.external_users.joins(:user)
        query = "lower(users.first_name || ' ' || users.last_name) ILIKE :term"
        @external_users = @external_users.where(query, term: "%#{params[:search]}%") if params[:search].present?
        @external_users = @external_users.ordered_by_last_name
      end

      def show; end

      def new
        @external_user = ExternalUser.new(provider_id: current_provider.id)
        @external_user.build_user
      end

      def edit; end

      def change_password; end

      def create
        @external_user = ExternalUser.new(params_with_temporary_password.merge(provider_id: current_provider.id))
        if @external_user.save
          deliver_reset_password_instructions(@external_user.user)
          redirect_to external_users_admin_external_users_url, notice: t('.notice')
        else
          render :new
        end
      end

      def update
        if @external_user.update(external_user_params)
          redirect_path = @external_user.admin? ? external_users_admin_external_users_url : external_users_claims_path
          redirect_to redirect_path, notice: t('.notice')
        else
          render :edit
        end
      end

      # NOTE: update_password in PasswordHelper

      def destroy
        @external_user.soft_delete
        redirect_to external_users_admin_external_users_url, notice: t('.notice')
      end

      private

      def current_provider
        @current_provider ||= current_user.persona.provider
      end

      def set_external_user
        @external_user = ExternalUser.find(params[:id])
      end

      def external_user_params
        current_user.persona.admin? ? admin_external_user_params : non_privileged_external_user_params
      end

      def admin_external_user_params
        params.require(:external_user).permit(
          :vat_registered,
          :supplier_number,
          roles: [],
          user_attributes: ATTRIBUTES
        )
      end

      def non_privileged_external_user_params
        params.require(:external_user).permit(
          :vat_registered,
          :supplier_number,
          user_attributes: ATTRIBUTES
        )
      end
    end
  end
end
