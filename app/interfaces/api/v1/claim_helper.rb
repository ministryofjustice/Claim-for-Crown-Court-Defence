module API::V1
  module ClaimHelper
    extend Grape::API::Helpers

    params :common_params do
      # REQUIRED params (note: use optional but describe as required in order to let model validations bubble-up)
      optional :api_key, type: String, desc: "REQUIRED: The API authentication key of the provider"
      optional :creator_email, type: String, desc: "REQUIRED: The ADP administrator account email address that uniquely identifies the creator of the claim."
      optional :court_id, type: Integer, desc: "REQUIRED: The unique identifier for this court"
      optional :case_type_id, type: Integer, desc: "REQUIRED: The unique identifier of the case type"
      optional :offence_id, type: Integer, desc: "REQUIRED: The unique identifier for this offence. For advocate claims, " +
                                                 "use an id from the list provided by the /api/offences endpoint, for all " +
                                                  "litigator claims, use the lgfs_offence_id from the list provided by the /api/offence_classes endpoint."
      optional :case_number, type: String, desc: "REQUIRED: The case number"
      optional :cms_number, type: String, desc: "OPTIONAL: The CMS number"
      optional :additional_information, type: String, desc: "OPTIONAL: Any additional information"
      optional :apply_vat, type: Boolean, desc: "OPTIONAL: Include VAT (JSON Boolean data type: true or false)"
    end

    def build_arguments
      declared_params.merge(source: claim_source, creator_id: claim_creator.id, external_user_id: claim_user.id)
    end
  end
end
