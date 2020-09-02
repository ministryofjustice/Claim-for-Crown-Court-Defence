module ClaimCSVHelpers
  extend ActiveSupport::Concern

  COMPLETED_STATES = %w[rejected refused authorised part_authorised].freeze
  SUBMITTED_STATES = %w[submitted redetermination awaiting_written_reasons].freeze

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
end
