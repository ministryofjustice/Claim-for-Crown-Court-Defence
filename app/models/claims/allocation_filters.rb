#
# mixin for scopes used to filter claims for allocating to case workers
#
# Note the state of the claim is not specified and is typical appended
# by the calling method:
#  e.g. @claims.where(state: :submitted).risk_based_bills
#
module Claims::AllocationFilters
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval { add_scopes }
  end

  module ClassMethods
    def add_scopes
      agfs_lgfs_scopes
      agfs_scopes
      lgfs_scopes
    end

    def agfs_lgfs_scopes
      scope :fixed_fee,   -> { all_fixed_fee }
    end

    def agfs_scopes
      scope :cracked,     -> { where(case_type_id: CaseType.ids_by_types('Cracked Trial', 'Cracked before retrial')) }
      scope :trial,       -> { where(case_type_id: CaseType.ids_by_types('Trial', 'Retrial')) }
      scope :guilty_plea, -> { where(case_type_id: CaseType.ids_by_types('Guilty plea', 'Discontinuance')) }
    end

    def lgfs_scopes
      scope :graduated_fees,        -> { all_graduated_fees }
      scope :risk_based_bills,      -> { all_risk_based_bills }
      scope :interim_fees,          -> { all_interim_fees }
      scope :warrants,              -> { all_interim_warrants }
      scope :interim_disbursements, -> { all_interim_disbursements }
    end

    def all_fixed_fee
      where(case_type: CaseType.fixed_fee).or(where(allocation_type: 'Fixed'))
    end

    def all_graduated_fees
      where(case_type: CaseType.graduated_fees).or(where(allocation_type: 'Grad'))
    end

    # An "interim fees" filter is for claims that are of type Claim::InterimClaim and have an interim fee that is of
    # type Effective PCMH, Trial Start, Retrial New Solicitor or Retrial Start
    def all_interim_fees
      interim_fee_types = ['Effective PCMH', 'Trial Start', 'Retrial New Solicitor', 'Retrial Start']
      where(type: 'Claim::InterimClaim')
        .joins(:fees)
        .where(fees: { fee_type: Fee::InterimFeeType.where(description: interim_fee_types) })
    end

    # A "warrants" filter is for claims that are of Type Claim::InterimClaim and have a fee type of Warrant
    def all_interim_warrants
      all_interims_with_fee_type('Warrant')
    end

    # An "interim disbursements" filter is for claims that are of
    # Type Claim::InterimClaim and have a fee type of disbursement only
    def all_interim_disbursements
      all_interims_with_fee_type('Disbursement only')
    end

    def all_interims_with_fee_type(fee_type_description)
      where(type: 'Claim::InterimClaim')
        .joins(:fees)
        .where('"fees"."fee_type_id" = ?',
               Fee::InterimFeeType.where(description: fee_type_description).pick(:id))
    end
  end
end
