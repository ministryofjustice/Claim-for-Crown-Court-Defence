module Claims::Search
  QUERY_MAPPINGS_FOR_SEARCH = {
    case_number: {
      query: 'claims.case_number ILIKE :term'
    },
    defendant_name: {
      joins: :defendants,
      query: "lower(defendants.first_name || ' ' || defendants.last_name) ILIKE :term "
    },
    advocate_name: {
      joins: { external_user: :user },
      query: "lower(users.first_name || ' ' || users.last_name) ILIKE :term"
    },
    maat_reference: {
      joins: { defendants: :representation_orders }, query: 'representation_orders.maat_reference ILIKE :term'
    },
    case_worker_name_or_email: {
      joins: { case_workers: :user },
      query: "lower(users.first_name || ' ' || users.last_name) ILIKE :term OR lower(users.email) ILIKE :term"
    }
  }.freeze

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  def search(term, states = [], *options)
    raise 'Invalid search option' if (options - QUERY_MAPPINGS_FOR_SEARCH.keys).any?
    term = term.to_s.strip.downcase

    if term.present?
      sql = options.inject([]) { |a, e| a << "(#{QUERY_MAPPINGS_FOR_SEARCH[e][:query]})" }.join(' OR ')
      relation = options.inject(all) { |a, e| a.joins(QUERY_MAPPINGS_FOR_SEARCH[e][:joins]) }
    else
      relation = all
    end

    states ||= Claims::StateMachine.dashboard_displayable_states
    states = Array[states] unless states.is_a?(Array)
    states.each do |state|
      next if Claim::BaseClaim.state_machine.states.map(&:name).include?(state.to_sym)
      raise "Invalid state, #{state}, specified"
    end

    relation = relation.active
    relation = relation.where(sql, term: "%#{term}%") if term.present?
    relation = relation.where(state: states) if states.present?
    from(relation.group('claims.id'), 'claims')
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
end
