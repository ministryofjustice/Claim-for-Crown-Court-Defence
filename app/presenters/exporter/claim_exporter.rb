class Exporter::ClaimExporter

  def initialize(claim)
    @claim = claim
  end

  def to_h
    {
      claim: {
        claim_details: {
          uuid: @claim.uuid,
          type: @claim.pretty_type,
          provider_code: @claim.supplier_number,
          created_by: {
            first_name: @claim.creator.first_name,
            last_name: @claim.creator.last_name,
            email: @claim.creator.email
          },
          external_user: {
            first_name: @claim.external_user.first_name,
            last_name: @claim.external_user.last_name,
            email: @claim.external_user.email
          },
          advocate_category: @claim.advocate_category,
          additional_information: @claim.additional_information,
          apply_vat: @claim.apply_vat,
          submitted_at: @claim.last_submitted_at,
          originally_submitted_at: @claim.original_submission_date,
          state: @claim.state,
          authorised_at: @claim.authorised_at
        },
      case_details: {
        case_type: @claim.case_type.name,
        court: {
          name: @claim.court.name,
          code: @claim.court.code
        },
        case_number: @claim.case_number,
        transfer: {
          court: {
            name: @claim.transfer_court&.name,
            code: @claim.transfer_court&.code
          },
          case_number: @claim&.transfer_case_number
        }
      }
    }
  }
  end
end