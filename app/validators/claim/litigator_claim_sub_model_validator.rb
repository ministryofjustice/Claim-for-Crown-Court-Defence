class Claim::LitigatorClaimSubModelValidator < Claim::BaseClaimSubModelValidator
  def has_one_association_names_for_steps
    {
      case_details: [],
      defendants: [],
      offence_details: [],
      fixed_fees: %i[fixed_fee],
      graduated_fees: %i[graduated_fee],
      warrant_fees: %i[warrant_fee]
      # fees: %i[
      #   graduated_fee
      #   fixed_fee
      #   warrant_fee
      #   assessment
      #   certification
      # ]
    }
  end

  def has_many_association_names_for_steps
    {
      case_details: [],
      defendants: %i[defendants],
      offence_details: [],
      miscellaneous_fees: %i[misc_fees],
      disbursements: %i[disbursements],
      travel_expenses: %i[expenses],
      supporting_evidence: %i[documents]
      # fees: %i[
      #   misc_fees
      #   disbursements
      #   expenses
      #   messages
      #   redeterminations
      #   documents
      # ]
    }
  end

  private

  def associations_for_has_many_validations(record)
    has_many_association_names_for_steps.select do |k, _v|
      record.submission_current_flow.map(&:to_sym).include?(k)
    end.values.flatten
  end

  def associations_for_has_one_validations(record)
    has_one_association_names_for_steps.select do |k, _v|
      record.submission_current_flow.map(&:to_sym).include?(k)
    end.values.flatten
  end
end
