module Claims::Search

  QUERY_MAPPINGS_FOR_SEARCH = {
    defendant_name: {
      joins: :defendants,
      query: "lower(defendants.first_name || ' ' || defendants.last_name) ILIKE :term "
    },
    advocate_name: {
      joins: { external_user: :user },
      query: "lower(users.first_name || ' ' || users.last_name) ILIKE :term"
    },
    maat_reference: {
      joins: {:defendants => :representation_orders}, query: "representation_orders.maat_reference ILIKE :term"
    },
    case_worker_name_or_email: {
      joins: { case_workers: :user },
      query: "lower(users.first_name || ' ' || users.last_name) ILIKE :term OR lower(users.email) ILIKE :term"
    }
  }

  def search(term, states=[], *options)
    raise 'Invalid search option' if (options - QUERY_MAPPINGS_FOR_SEARCH.keys).any?
    sql = options.inject([]) { |r, o| r << "(#{QUERY_MAPPINGS_FOR_SEARCH[o][:query]})" }.join(' OR ')
    relation = options.inject(all) { |r, o| r = r.joins(QUERY_MAPPINGS_FOR_SEARCH[o][:joins]) }

    states ||= Claims::StateMachine.dashboard_displayable_states
    states = Array[states] unless states.is_a?(Array)
    states.each do |state|
      raise "Invalid state, #{state}, specified" unless Claim::BaseClaim.state_machine.states.map(&:name).include?(state.to_sym)
    end

    relation.where(sql, term: "%#{term.downcase}%").where(state: states).uniq
  end
end
