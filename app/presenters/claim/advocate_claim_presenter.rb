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
end
