class ManagementInformationPresenter < BasePresenter
  presents :claim

  include ManagementInformationReportable

  SORTED_AND_FILTERED_STATES = %w[draft archived_pending_delete archived_pending_review].freeze

  def present!
    yield parsed_journeys if block_given?
  end

  def parsed_journeys
    journeys.map do |journey|
      @journey = clean_deallocations(journey)
      Settings.claim_csv_headers.map { |method_call| send(method_call) } if @journey.any?
    end
  end

  # cuts of transitions into chunks with each chunked ending with a completed state
  # 1. so [submitted, allocated, rejected, reterminined, allocated, part_authorised]
  # would break into [[submitted, allocated, rejected], [reterminined, allocated, part_authorised]]
  # 2. so [submitted, allocated]
  # would break into [submitted, allocated]
  def journeys
    sorted_and_filtered_state_transitions.slice_after { |transition| COMPLETED_STATES.include?(transition.to) }
  end

  # orders by primary key ascending by default
  def sorted_and_filtered_state_transitions
    claim_state_transitions.sort.reject do |transition|
      SORTED_AND_FILTERED_STATES.include?(transition.to) ||
        transition.created_at < Time.zone.now - 6.months
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

  def previous(next_step)
    complete_journeys = sorted_and_filtered_state_transitions
    complete_journeys.select { |step| step.to == next_step.from && step.created_at < next_step.created_at }
  end
end
