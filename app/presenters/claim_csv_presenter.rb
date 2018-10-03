class ClaimCsvPresenter < BasePresenter
  presents :claim

  COMPLETED_STATES = %w[rejected refused authorised part_authorised].freeze
  SUBMITTED_STATES = %w[submitted redetermination awaiting_written_reasons].freeze

  def present!
    yield parsed_journeys if block_given?
  end

  def journeys
    sorted_and_filtered_state_transitions.slice_after { |transition| COMPLETED_STATES.include?(transition.to) }
  end

  def sorted_and_filtered_state_transitions
    claim_state_transitions.sort.reject do |transition|
      %w[draft archived_pending_delete].include?(transition.to) ||
        transition.created_at < Time.now - 6.months
    end
  end

  def parsed_journeys
    journeys.map do |journey|
      @journey = clean_deallocations(journey)
      Settings.claim_csv_headers.map { |method_call| send(method_call) } if @journey.any?
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
    if claim.allocated?
      claim.case_workers.first.name
    else
      transition = claim.last_decision_transition
      transition&.author_name
    end
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
    case_type&.name || ''
  end

  def scheme
    if %w[Claim::AdvocateClaim Claim::AdvocateInterimClaim].include? type
      'AGFS'
    elsif %w[Claim::LitigatorClaim Claim::InterimClaim Claim::TransferClaim].include? type
      'LGFS'
    else
      'Unknown'
    end
  end

  def disk_evidence_case
    disk_evidence ? 'Yes' : 'No'
  end

  def claim_total
    total_including_vat.to_s
  end

  def submission_type
    @journey.first.to == 'submitted' ? 'new' : @journey.first.to
  end

  def submitted_at
    submission_steps = @journey.select { |step| SUBMITTED_STATES.include?(step.to) }
    submission_steps.present? ? submission_steps.first.created_at.strftime('%d/%m/%Y') : 'n/a'
  end

  def allocated_at
    allocation_steps = @journey.select { |step| step.to == 'allocated' }
    allocation_steps.present? ? allocation_steps.last.created_at.strftime('%d/%m/%Y') : 'n/a'
  end

  def completed_at
    completion_steps = @journey.select { |step| COMPLETED_STATES.include?(step.to) }
    completion_steps.present? ? completion_steps.first.created_at.strftime('%d/%m/%Y') : 'n/a'
  end

  def current_or_end_state
    state = @journey.last.to
    SUBMITTED_STATES.include?(state) ? 'submitted' : state
  end

  def state_reason_code
    reason_code = @journey.last.reason_code
    reason_code = reason_code.flatten.join(', ') if reason_code.is_a?(Array)
    reason_code
  end

  def rejection_reason
    @journey.last.reason_text
  end
end
