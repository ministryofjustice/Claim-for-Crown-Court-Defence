module API
  module V1
    module ClaimParamsHelper
      extend Grape::API::Helpers
      AGFS_SCOPE = %i[api v1 external_users claims advocate_claim params].freeze

      # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
      #
      params :common_params do
        optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
        optional :creator_email, type: String, desc: I18n.t('api.v1.common_params.creator_email')
        optional :court_id, type: Integer, desc: 'REQUIRED: The unique identifier for this court'
        optional :case_type_id, type: Integer, desc: 'REQUIRED: The unique identifier of the case type'
        optional :offence_id, type: Integer, desc: 'REQUIRED: The unique identifier for this offence.'
        optional :case_number, type: String, desc: 'REQUIRED: The case number'
        optional :providers_ref, type: String, desc: 'OPTIONAL: Providers reference number'
        optional :cms_number, type: String, desc: 'OPTIONAL: The CMS number'
        optional :additional_information, type: String, desc: 'OPTIONAL: Any additional information'
        optional :apply_vat, type: Boolean, desc: 'OPTIONAL: Include VAT (JSON Boolean data type: true or false)'
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
        optional :transfer_case_number, type: String, desc: 'OPTIONAL: The case number for the transfer court.'
      end

      params :legacy_agfs_params do
        optional :advocate_email, type: String, desc: local_t(:advocate_email, AGFS_SCOPE)
        use :user_email
      end

      params :common_agfs_params do
        optional :actual_trial_length, type: Integer, desc: local_t(:actual_trial_length, AGFS_SCOPE)
        optional :retrial_actual_length, type: Integer, desc: local_t(:retrial_actual_length, AGFS_SCOPE)
        optional :retrial_concluded_at,
                 type: String,
                 desc: local_t(:retrial_concluded_at, AGFS_SCOPE),
                 standard_json_format: true
        optional :retrial_reduction,
                 type: Boolean,
                 desc: local_t(:retrial_reduction, AGFS_SCOPE),
                 documentation: { default: false }

        optional :trial_fixed_notice_at,
                 type: String, desc:
                     local_t(:trial_fixed_notice_at, AGFS_SCOPE),
                 standard_json_format: true
        optional :trial_fixed_at, type: String, desc: local_t(:trial_fixed_at, AGFS_SCOPE), standard_json_format: true
        optional :trial_cracked_at,
                 type: String,
                 desc: local_t(:trial_cracked_at, AGFS_SCOPE),
                 standard_json_format: true
        optional :trial_cracked_at_third,
                 type: String,
                 desc: local_t(:trial_cracked_at_third, AGFS_SCOPE),
                 values: Settings.trial_cracked_at_third
      end

      params :user_email do
        optional :user_email, type: String, desc: I18n.t('api.v1.common_params.user_email')
      end

      def build_arguments
        declared_params.merge(source: claim_source, creator_id: claim_creator.id, external_user_id: claim_user.id)
      end
    end
  end
end
