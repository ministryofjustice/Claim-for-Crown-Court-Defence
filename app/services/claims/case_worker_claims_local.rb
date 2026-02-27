module Claims
  class CaseWorkerClaimsLocal
    PERMITTED = {
      actions: %w[current archived],
      columns: %w[case_number last_submitted_at],
      directions: %w[asc desc]
    }.freeze

    def initialize(current_user:, action:, sort_column: nil, sort_direction: nil)
      @current_user = current_user
      @action = fetch_permitted(:actions, action, default: 'current')
      @sort_column = fetch_permitted(:columns, sort_column)
      @sort_direction = fetch_permitted(:directions, sort_direction, default: 'asc')
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
        position: claim_ids.index(claim.id) + 1,
        count: claim_ids.count,
        items: items(claim)
      }
    end

    private

    def claim_ids = @claim_ids ||= claims.pluck(:id)

    def previous_claim_id(claim)
      return if claim_ids.first == claim.id

      claim_ids[claim_ids.index(claim.id) - 1]
    end

    def next_claim_id(claim)
      return if claim_ids.last == claim.id

      claim_ids[claim_ids.index(claim.id) + 1]
    end

    def items(claim)
      [
        ({ number: 1 } if claim_ids.first != claim.id),
        ({ ellipsis: true } if claim_ids[0, 2].exclude?(claim.id)),
        { number: claim_ids.index(claim.id) + 1, current: true },
        ({ ellipsis: true } if claim_ids[-2, 2].exclude?(claim.id)),
        ({ number: claim_ids.count } if claim_ids.last != claim.id)
      ].compact
    end

    def fetch_permitted(key, value, default: nil) = PERMITTED[key].include?(value) ? value : default

    def sorted(claims)
      return claims if @sort_column.nil?

      claims.sort_using(@sort_column, @sort_direction)
    end

    def current_claims
      @current_user.claims.where(id: Claim::BaseClaim.search('', Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES))
    end

    def archived_claims
      Claim::BaseClaim.active.search('', Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES)
    end
  end
end
