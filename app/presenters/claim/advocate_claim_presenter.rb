class Claim::AdvocateClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :basic_fees_total, :fixed_fees_total

  def pretty_type
    'AGFS Final'
  end

  def type_identifier
    'agfs_final'
  end

  def can_have_disbursements?
    false
  end

  def raw_fixed_fees_total
    claim.calculate_fees_total(:fixed)
  end

  def raw_basic_fees_total
    claim.calculate_fees_total(:basic)
  end

  def raw_fixed_fees_combined_total
    raw_fixed_fees_total + raw_basic_fees_total + raw_misc_fees_total
  end

  def summary_sections
    # NOTE: ideally this would use the claim current stages
    # unfortunately they don't map 1-2-1
    %i[case_details defendants offence_details basic_fees fixed_fees misc_fees
       expenses supporting_evidence additional_information]
  end
end
