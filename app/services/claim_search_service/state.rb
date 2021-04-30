class ClaimSearchService
  class State < Base
    STATES = {
      archived: Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES,
      allocated: Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES
    }.freeze

    def initialize(search, status:)
      super

      @status = status
    end

    def run
      @search.run.where(state: STATES[@status])
    end

    def self.decorate(search, status: nil, **_params)
      status = status&.to_sym
      return search if STATES[status].blank?

      new(search, status: status)
    end
  end
end
