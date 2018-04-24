class Claim::InterimClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :interim_fees_total, :warrant_fees_total

  def requires_trial_dates?
    false
  end

  def requires_retrial_dates?
    false
  end

  def can_have_expenses?
    false
  end

  def disbursement_only?
    claim.interim_fee&.is_disbursement?
  end

  def pretty_type
    'LGFS Interim'
  end

  def type_identifier
    'lgfs_interim'
  end

  def raw_interim_fees_total
    claim.interim_fee&.amount || 0
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
  end

  def summary_sections
    # NOTE: ideally this would use the claim current stages
    # unfortunately they don't map 1-2-1
    %i[case_details defendants offence_details interim_fee
       expenses supporting_evidence additional_information]
  end
end
