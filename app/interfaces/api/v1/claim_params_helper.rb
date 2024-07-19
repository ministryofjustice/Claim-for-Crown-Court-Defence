module API
  module V1
    module ClaimParamsHelper
      extend Grape::API::Helpers
      # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
      #
      params :common_params do
        optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
        optional :creator_email, type: String, desc: I18n.t('api.v1.common_params.creator_email')
        optional :court_id, type: Integer, desc: 'REQUIRED: The unique identifier for this court'
        optional :case_type_id, type: Integer, desc: 'REQUIRED: The unique identifier of the case type'
        optional :offence_id, type: Integer, desc: 'REQUIRED: The unique identifier for this offence.'
        optional :case_number, type: String, desc: 'REQUIRED: The case number or URN'
        optional :providers_ref, type: String, desc: 'OPTIONAL: Providers reference number'
        optional :cms_number, type: String, desc: 'OPTIONAL: The CMS number'
        optional :additional_information, type: String, desc: 'OPTIONAL: Any additional information'
        optional :travel_expense_additional_information,
                 type: String,
                 desc: I18n.t('api.v1.common_params.travel_expense_additional_information')
        optional :apply_vat, type: Boolean, desc: 'OPTIONAL: Include VAT (JSON Boolean data type: true or false)'
        optional :prosecution_evidence, type: Boolean, desc: 'OPTIONAL: Pages of prosecution evidence > 0?'
      end

      params :common_trial_params do
        optional :first_day_of_trial, type: String, desc: 'REQUIRED for trials: YYYY-MM-DD', standard_json_format: true
        optional :estimated_trial_length, type: Integer, desc: 'REQUIRED for trials: The estimated trial length in days'
        optional :trial_concluded_at,
                 type: String,
                 desc: 'REQUIRED for trials: The date the trial concluded (YYYY-MM-DD)',
                 standard_json_format: true
        optional :retrial_started_at,
                 type: String,
                 desc: 'REQUIRED for retrials: YYYY-MM-DD', standard_json_format: true
        optional :retrial_estimated_length,
                 type: Integer,
                 desc: 'REQUIRED for retrials: The estimated retrial length in days'
      end

      params :common_lgfs_params do
        use :user_email
        optional :supplier_number, type: String, desc: 'REQUIRED. The supplier number.'
        optional :transfer_court_id, type: Integer, desc: 'OPTIONAL: The unique identifier for the transfer court.'
        optional :transfer_case_number, type: String, desc: 'OPTIONAL: The case number or URN for the transfer court.'
        optional :london_rates_apply,
                 type: Boolean,
                 desc: 'OPTIONAL: Whether the firm for the claim is based in a London Borough or not'
      end

      params :legacy_agfs_params do
        optional :advocate_email, type: String, desc: local_t(:advocate_email)
        use :user_email
      end

      params :common_agfs_params do
        optional :actual_trial_length, type: Integer, desc: local_t(:actual_trial_length)
        optional :retrial_actual_length, type: Integer, desc: local_t(:retrial_actual_length)
        optional :retrial_concluded_at,
                 type: String,
                 desc: local_t(:retrial_concluded_at),
                 standard_json_format: true
        optional :retrial_reduction,
                 type: Boolean,
                 desc: local_t(:retrial_reduction),
                 documentation: { default: false }

        optional :trial_fixed_notice_at,
                 type: String, desc:
                     local_t(:trial_fixed_notice_at),
                 standard_json_format: true
        optional :trial_fixed_at, type: String, desc: local_t(:trial_fixed_at), standard_json_format: true
        optional :trial_cracked_at,
                 type: String,
                 desc: local_t(:trial_cracked_at),
                 standard_json_format: true
        optional :trial_cracked_at_third,
                 type: String,
                 desc: local_t(:trial_cracked_at_third),
                 values: Settings.trial_cracked_at_third
      end

      params :user_email do
        optional :user_email, type: String, desc: I18n.t('api.v1.common_params.user_email')
      end

      params :advocate_category_all do
        optional :advocate_category,
                 type: String,
                 desc: local_t(:advocate_category),
                 values: Settings.advocate_categories | Settings.agfs_reform_advocate_categories |
                         Settings.new_monarch_advocate_categories
      end

      params :advocate_category_agfs_reform do
        optional :advocate_category,
                 type: String,
                 desc: local_t(:advocate_category),
                 values: Settings.agfs_reform_advocate_categories | Settings.new_monarch_advocate_categories
      end

      def build_arguments
        declared_params.merge(source: claim_source, creator_id: claim_creator.id, external_user_id: claim_user.id)
      end

      # Add a Sunset/deprecation header into HTTP Response for clients to sniff on
      # https://tools.ietf.org/html/draft-wilde-sunset-header-03
      def sunset(datetime:, link: nil)
        header 'Sunset', datetime.httpdate
        header 'Link', format('<%{link}>; rel="sunset";', link:) if link.present?
        ActiveSupport::Deprecation.warn("deprecated endpoint #{namespace} (sunset date #{datetime.iso8601}) has been called by #{request.headers['User-Agent']}")
      end
      alias deprecate sunset
    end
  end
end
