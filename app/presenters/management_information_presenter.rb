class ManagementInformationPresenter < BasePresenter
  presents :claim

  include ManagementInformationReportable

  def present!
    yield parsed_journeys if block_given?
  end

  def journeys
    sorted_and_filtered_state_transitions.slice_after { |transition| COMPLETED_STATES.include?(transition.to) }
  end

  def sorted_and_filtered_state_transitions
    claim_state_transitions.sort.reject do |transition|
      %w[draft archived_pending_delete archived_pending_review].include?(transition.to) ||
        transition.created_at < Time.zone.now - 6.months
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

  def claim_state
    if state == 'archived_pending_delete'
      claim_state_transitions.claim_state_transitions.sort.last.from
    else
      state
    end
  end

  def previous(next_step)
    complete_journeys = sorted_and_filtered_state_transitions
    complete_journeys.select { |step| step.to == next_step.from && step.created_at < next_step.created_at }
  end
end
