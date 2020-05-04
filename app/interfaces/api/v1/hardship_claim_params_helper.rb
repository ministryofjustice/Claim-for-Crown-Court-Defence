module API
  module V1
    module HardshipClaimParamsHelper
      extend Grape::API::Helpers
      # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
      #
      params :lgfs_hardship_params do
        optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
        optional :creator_email, type: String, desc: I18n.t('api.v1.common_params.creator_email')
        optional :court_id, type: Integer, desc: 'REQUIRED: The unique identifier for this court'
        optional :offence_id, type: Integer, desc: 'REQUIRED: The unique identifier for this offence.'
        optional :case_number, type: String, desc: 'REQUIRED: The case number'
        optional :providers_ref, type: String, desc: 'OPTIONAL: Providers reference number'
        optional :cms_number, type: String, desc: 'OPTIONAL: The CMS number'
        optional :additional_information, type: String, desc: 'OPTIONAL: Any additional information'
        optional :apply_vat, type: Boolean, desc: 'OPTIONAL: Include VAT (JSON Boolean data type: true or false)'
        optional :prosecution_evidence, type: Boolean, desc: 'OPTIONAL: Pages of prosecution evidence > 0?'
        optional :case_stage_unique_code, type: String, desc: 'REQUIRED: The unique code for the case stage.'
      end
    end
  end
end
