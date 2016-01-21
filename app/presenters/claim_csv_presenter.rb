class ClaimCsvPresenter < BasePresenter

  presents :claim

  def present!
    state_transitions = claim_state_transitions.sort.reject {|transition| (transition.from == nil || transition.to == 'archived_pending_delete') }
    journeys = state_transitions.slice_after {|transition| completed_states.include?(transition.to) }
    parsed_journeys = parse(journeys)
    yield parsed_journeys
  end

  def parse(journeys)
    journeys.map do |journey|
      @journey = journey
      Settings.claim_csv_headers.map {|method_call| send(method_call)}
    end
  end

  def claim_details
    Settings.csv_claim_details.map { |detail| send(detail) }
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

  def submission_type
    @journey.first.to == 'submitted' ? 'new' : @journey.first.to
  end

  def submitted_at
    @journey.select { |step| submitted_states.include?(step.to) }.first.created_at
  end

  def allocated_at
    allocations = @journey.select { |step| step.to == 'allocated' }
    allocations.present? ? allocations.first.created_at : 'n/a'
  end

  def completed_at
    completed_state = @journey.select { |step| completed_states.include?(step.to) }.first
    completed_state.present? ? completed_state.created_at : 'n/a'
  end

  def current_or_end_state
    @journey.last.to
  end

  def submitted_states
    ['submitted', 'redetermination', 'awaiting_written_reasons']
  end

  def completed_states
    ['rejected', 'refused', 'authorised', 'part_authorised']
  end

end
