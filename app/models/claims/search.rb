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

  def search(term, states = [], *options)
    raise 'Invalid search option' if (options - QUERY_MAPPINGS_FOR_SEARCH.keys).any?
    sql = options.inject([]) { |a, e| a << "(#{QUERY_MAPPINGS_FOR_SEARCH[e][:query]})" }.join(' OR ')
    relation = options.inject(all) { |a, e| a.joins(QUERY_MAPPINGS_FOR_SEARCH[e][:joins]) }

    states ||= Claims::StateMachine.dashboard_displayable_states
    states = Array[states] unless states.is_a?(Array)
    states.each do |state|
      raise "Invalid state, #{state}, specified" unless Claim::BaseClaim.state_machine.states.map(&:name).include?(state.to_sym)
    end

    relation.active.where(sql, term: "%#{term.strip.downcase}%").where(state: states).uniq
  end
end
