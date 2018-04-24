class Claim::LitigatorClaimPresenter < Claim::BaseClaimPresenter
  # TODO: Any differences in baseclaimpresenters for litigators and advocates to be handled here
  present_with_currency :fixed_fees_total, :warrant_fees_total, :grad_fees_total

  def pretty_type
    'LGFS Final'
  end

  def type_identifier
    'lgfs_final'
  end

  def fixed_fees
    [claim.fixed_fee].compact
  end

  def raw_fixed_fees_total
    claim.fixed_fee&.amount || 0
  end

  def raw_grad_fees_total
    claim.graduated_fee&.amount || 0
  end

  def raw_warrant_fees_total
    claim.warrant_fee&.amount || 0
  end

  def summary_sections
    # NOTE: ideally this would use the claim current stages
    # unfortunately they don't map 1-2-1
    %i[case_details defendants offence_details fixed_fees graduated_fees misc_fees
       disbursements expenses supporting_evidence additional_information]
  end
end
