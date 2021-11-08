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

  def journeys
    sorted_and_filtered_state_transitions.slice_after { |transition| COMPLETED_STATES.include?(transition.to) }
  end

  def sorted_and_filtered_state_transitions
    claim_state_transitions.sort.reject do |transition|
      SORTED_AND_FILTERED_STATES.include?(transition.to) ||
        # This is equivalent to
        #   `Time.zone.now - 6.months >= transition.created_at`
        #
        # TODO: This is very brittle and confusing as it means:
        # 1. it is based on what TIME the report is run.
        # 2. it will not include transitions that occured exactly 6 months ago
        # 3. it will not include transitions 6 months before the time the report is run (to the second/sub-second)
        # 4. makes testing it time sensitive (to when the test is run, to the nearest micro-second potentially)
        #
        # Instead we should truncate the datetime to date and compare to `6.months.ago.beginning_of_day`
        # i.e. transition.created_at.beginning_of_day < 6.months.ago.beginning_of_day
        #
        # I am leaving for now to emulate this behaviour in SQL as is, using a diff of v1 and v2
        # against prod-like data set
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
