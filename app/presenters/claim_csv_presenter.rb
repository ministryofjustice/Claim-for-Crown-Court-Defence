class ClaimCsvPresenter < BasePresenter

  presents :claim

  def present!
    yield parsed_journeys
  end

  def journeys
    sorted_and_filtered_state_transitions.slice_after {|transition| completed_states.include?(transition.to) }
  end

  def sorted_and_filtered_state_transitions
    claim_state_transitions.sort.reject {|transition| (transition.to == 'draft' || transition.to == 'archived_pending_delete') }
  end

  def parsed_journeys
    journeys.map do |journey|
      @journey = journey
      Settings.claim_csv_headers.map {|method_call| send(method_call)}
    end
  end

  def claim_details
    Settings.csv_claim_details.map { |detail| send(detail) }
  end

  def supplier_number
    if external_user.nil?
       puts ">>>>>>>>>>> EXTERNAM USER NIL +++++++ #{__FILE__}::#{__LINE__} <<<<<<<<<"
       ap claim
       puts callback
       raise "Bang"
     end
    external_user.supplier_number
  end

  def claim_state
    unless state == 'archived_pending_delete'
      state
    else
      claim_state_transitions.sort.last.from
    end
  end

  def organisation
    external_user.provider.name
  end

  def case_type_name
    case_type.name
  end

  def claim_total
    total_including_vat.to_s
  end

  def submission_type
    @journey.first.to == 'submitted' ? 'new' : @journey.first.to
  end

  def submitted_at
    submission_steps = @journey.select { |step| submitted_states.include?(step.to) }
    submission_steps.present? ? submission_steps.first.created_at.to_s : 'n/a'
  end

  def allocated_at
    allocation_steps = @journey.select { |step| step.to == 'allocated' }
    allocation_steps.present? ? allocation_steps.first.created_at.to_s : 'n/a'
  end

  def completed_at
    completion_steps = @journey.select { |step| completed_states.include?(step.to) }
    completion_steps.present? ? completion_steps.first.created_at.to_s : 'n/a'
  end

  def current_or_end_state
    state = @journey.last.to
    submitted_states.include?(state) ? 'submitted' : state
  end

  def submitted_states
    ['submitted', 'redetermination', 'awaiting_written_reasons']
  end

  def completed_states
    ['rejected', 'refused', 'authorised', 'part_authorised']
  end

end
