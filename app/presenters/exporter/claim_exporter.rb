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
        },
        trial_dates: {
          date_started: @claim.first_day_of_trial,
          date_concluded: @claim.trial_concluded_at,
          estimated_length: @claim.estimated_trial_length,
          actual_length: @claim.actual_trial_length,
        },
        retrial_dates: {
          date_started: @claim.retrial_started_at,
          date_concluded: @claim.retrial_concluded_at,
          estimated_length: @claim.retrial_estimated_length,
          actual_length: @claim.retrial_actual_length,
        },
        cracked_dates: {
          date_fixed_notice: @claim.trial_fixed_notice_at,
          date_fixed: @claim.trial_fixed_at,
          date_cracked: @claim.trial_cracked_at,
          date_cracked_at_third: @claim.trial_cracked_at_third,
        },
        effective_pcmh_date: @claim.effective_pcmh_date,
        legal_aid_transfer_date: @claim.legal_aid_transfer_date,
        source: @claim.source,
        totals: {
          fees: @claim.fees_total,
          expenses: @claim.expenses_total,
          disbursement: @claim.disbursements_total,
          vat: @claim.vat_amount
        },
        cms_number: @claim.cms_number,
        providers_reference: @claim.providers_ref,
        evidence_checklist: evidence_checklist_hash,
        offence: {
          category: @claim.offence.description,
          class: @claim.offence.offence_class.description
        }
      },
      defendants: defendants_hash,

    }
  }
  end

  private

  def defendants_hash
    result = []
    defendants.each do |defendant|
      result << DefendantExporter.new(defendant).to_h
    end
    result
  end

  def evidence_checklist_hash
    array_of_docs = []
    @claim.evidence_checklist_ids.each do |evidence_doc_type_id|
      array_of_docs << { doc_type: DocType.find(evidence_doc_type_id).name }
    end
    array_of_docs
  end


end