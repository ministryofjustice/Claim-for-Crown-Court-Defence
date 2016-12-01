class ClaimCsvPresenter < BasePresenter

  presents :claim

  def present!
    yield parsed_journeys
  end

  def journeys
    sorted_and_filtered_state_transitions.slice_after {|transition| completed_states.include?(transition.to) }
  end

  def sorted_and_filtered_state_transitions
    claim_state_transitions.sort.reject { |transition| (transition.to == 'draft' || transition.to == 'archived_pending_delete') }
  end

  def parsed_journeys
    journeys.map do |journey|
      @journey = clean_deallocations(journey)
      Settings.claim_csv_headers.map { |method_call| send(method_call) }
    end
  end

  def clean_deallocations(journey)
    deallocation = journey.reverse.find { |transition| transition.event == 'deallocate' }
    if deallocation
      journey.reject! { |transition| transition.event == 'allocate' && transition.created_at < deallocation.created_at }
      journey.reject! { |transition| transition.event == 'deallocate' }
    end
    journey
  end

  def case_worker
    transition = claim.last_decision_transition
    transition&.author_name
  end

  def claim_state
    if state == 'archived_pending_delete'
      claim_state_transitions.sort.last.from
    else
      state
    end
  end

  def organisation
    provider.name
  end

  def case_type_name
    case_type.name
  end

  def scheme
    if type == 'Claim::AdvocateClaim'
      'AGFS'
    elsif %w( Claim::LitigatorClaim Claim::InterimClaim Claim::TransferClaim ).include? type
      'LGFS'
    else
      'Unknown'
    end
  end

  def claim_total
    total_including_vat.to_s
  end

  def submission_type
    @journey.first.to == 'submitted' ? 'new' : @journey.first.to
  end

  def submitted_at
    submission_steps = @journey.select { |step| submitted_states.include?(step.to) }
    submission_steps.present? ? submission_steps.first.created_at.strftime('%d/%m/%Y') : 'n/a'
  end

  def allocated_at
    allocation_steps = @journey.select { |step| step.to == 'allocated' }
    allocation_steps.present? ? allocation_steps.last.created_at.strftime('%d/%m/%Y') : 'n/a'
  end

  def completed_at
    completion_steps = @journey.select { |step| completed_states.include?(step.to) }
    completion_steps.present? ? completion_steps.first.created_at.strftime('%d/%m/%Y') : 'n/a'
  end

  def current_or_end_state
    state = @journey.last.to
    submitted_states.include?(state) ? 'submitted' : state
  end

  def state_reason_code
    @journey.last.reason_code
  end

  def submitted_states
    %w(submitted redetermination awaiting_written_reasons)
  end

  def completed_states
    %w(rejected refused authorised part_authorised)
  end
end
