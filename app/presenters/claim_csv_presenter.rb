class ClaimCsvPresenter < BasePresenter

  presents :claim

  CASE_TYPE_TO_ALLOCATION_TYPE = {
        'trial'                       => 'Trial',
        'retrial'                     => 'Trial',
        'cracked trial'               => 'Cracked',
        'cracked before retrial'      => 'Cracked',
        'guilty plea'                 => 'Guilty',
        'discontinuance'              => 'Guilty',
        'appeal against conviction'   => 'Fixed',
        'appeal against sentence'     => 'Fixed',
        'breach of crown court order' => 'Fixed',
        'committal for sentence'      => 'Fixed',
        'contempt'                    => 'Fixed',
        'elected cases not proceeded' => 'Fixed'
      }

  def present!
    Settings.csv_column_names.map { |column_name| send(column_name) }
  end

  def supplier_number
    advocate.supplier_number
  end

  def organisation
    advocate.provider.name
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
      CASE_TYPE_TO_ALLOCATION_TYPE[case_type_name.downcase]
    end
  end

end
