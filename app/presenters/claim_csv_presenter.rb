class ClaimCsvPresenter < BasePresenter

  presents :claim

  def present!
    Settings.csv_column_names.map { |column_name| send(column_name) }
  end

  def supplier_number
    external_user.supplier_number
  end

  def organisation
    external_user.provider.name
  end

  def case_type_name
    case_type.name
  end

  def claim_total
    total.to_s
  end

  def last_allocated_at
    last_allocation = versions.select { |version| version.changeset['state'][1] == 'allocated' }.last
    last_allocation ? last_allocation.created_at.to_s : 'n/a'
  end

  def last_determined_at
    last_determination = versions.select { |version| determined_states.include?(version.changeset['state'][1]) }.last
    last_determination ? last_determination.created_at.to_s : 'n/a'
  end

  def determined_states
    ['rejected', 'refused', 'authorised', 'part_authorised']
  end

  def allocation_type
    if claim.awaiting_written_reasons?
      'Written reasons'
    elsif claim.opened_for_redetermination?
      'Redetermination'
    else
      case_type_to_allocation_type
    end
  end

  def case_type_to_allocation_type
    if case_type.is_fixed_fee
      'Fixed'
    elsif case_type.requires_cracked_dates
      'Cracked'
    elsif case_type.requires_trial_dates
      'Trial'
    else
      'Guilty'
    end
  end

end
