module Claims
  class CaseWorkerClaimsLocal
    PERMITTED = {
      actions: %w[current archived],
      columns: %w[type case_number advocate total_inc_vat state case_type last_submitted_at],
      directions: %w[asc desc]
    }.freeze

    def initialize(current_user:, action:, sort_column: nil, sort_direction: nil, search: '')
      @current_user = current_user
      @action = fetch_permitted(:actions, action, default: 'current')
      @sort_column = fetch_permitted(:columns, sort_column)
      @sort_direction = fetch_permitted(:directions, sort_direction, default: 'asc')
      @search = search
    end

    def claims
      @claims ||= case @action
                  when 'current'
                    sorted(current_claims)
                  when 'archived'
                    sorted(archived_claims)
                  end
    end

    def navigation(claim)
      {
        previous: previous_claim_id(claim),
        next: next_claim_id(claim),
        position: position(claim),
        count: claim_ids.count
      }
    end

    private

    # pluck would be more efficient than map but it causes problems with some of the sorting options
    def claim_ids = @claim_ids ||= claims.map(&:id)

    def previous_claim_id(claim)
      return if claim_ids.first == claim.id
      return unless claim_ids.include?(claim.id)

      claim_ids[claim_ids.index(claim.id) - 1]
    end

    def next_claim_id(claim)
      return if claim_ids.last == claim.id
      return unless claim_ids.include?(claim.id)

      claim_ids[claim_ids.index(claim.id) + 1]
    end

    def position(claim)
      return unless claim_ids.include?(claim.id)

      claim_ids.index(claim.id) + 1
    end

    def fetch_permitted(key, value, default: nil) = PERMITTED[key].include?(value) ? value : default

    def sorted(claims)
      return claims if @sort_column.nil?

      claims.sort_using(@sort_column, @sort_direction)
    end

    def current_claims
      @current_user.claims.where(
        id: Claim::BaseClaim.search(
          @search, Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES, *search_options
        )
      )
    end

    def archived_claims
      Claim::BaseClaim.active.search(
        @search, Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES, *search_options
      )
    end

    def search_options
      options = %i[case_number maat_reference defendant_name]
      options << :case_worker_name_or_email if @current_user.persona.admin?
      options
    end
  end
end
