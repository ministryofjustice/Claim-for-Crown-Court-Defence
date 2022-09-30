module SuperAdmins
  module Admin
    class FeatureFlagsController < ApplicationController
      def show
        feature_flag
      end

      def update
        if feature_flag.update!(form_params)
          redirect_to super_admins_admin_feature_flags_path,
                      notice: I18n.t('super_admins.admin.feature_flags.show.notice')
        else
          render :show
        end
      end

      private

      def form_params
        params.require(:feature_flag).permit(:enable_new_monarch)
      end

      def feature_flag
        @feature_flag ||= FeatureFlag.feature_flag
      end
    end
  end
end
