class Claim::AdvocateInterimClaimPresenter < Claim::BaseClaimPresenter
  def pretty_type
    'AGFS Warrant'
  end

  def type_identifier
    'agfs_interim'
  end

  def can_have_disbursements?
    false
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
  end
  present_with_currency :warrant_fees_total

  def summary_sections
    # NOTE: ideally this would use the claim current stages
    # unfortunately they don't map 1-2-1
    %i[case_details defendants offence_details warrant_fee expenses supporting_evidence additional_information]
  end
end
