module ExternalUsers
  module Admin
    class ProvidersController < ExternalUsers::Admin::ApplicationController
      include ProviderAdminConcern

      before_action :set_provider, only: :regenerate_api_key

      def regenerate_api_key
        @provider.regenerate_api_key!
        redirect_to external_users_admin_provider_path(@provider), notice: t('.notice')
      end

      def edit
        render 'shared/providers/edit'
      end

      def update
        if @provider.update(provider_params.except(*filtered_params))
          redirect_to external_users_admin_provider_path, notice: t('.notice')
        else
          @error_presenter = error_presenter
          render 'shared/providers/edit'
        end
      end

      private

      def set_provider
        @provider = current_user.persona.provider
      end

      # This functionality was raised as a bug in 2018 when we were unable to edit a provider in demo.
      # After reviewing it is our assumption that, historically, a decision was made to prevent provider admins
      # from editing their provider_type and roles as this would have been set up by a super_admin and should only
      # be changed by another super_admin as there are a significant changes required in the data structure
      # when they change
      def filtered_params
        %i[roles provider_type]
      end

      def error_presenter
        ErrorMessage::Presenter.new(@provider, ErrorMessage.translation_file_for('provider'))
      end
    end
  end
end
