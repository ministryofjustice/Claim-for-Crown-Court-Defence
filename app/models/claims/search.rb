module Claims::Search

  QUERY_MAPPINGS_FOR_SEARCH = {
    defendant_name: {
      joins: :defendants,
      query: "lower(defendants.first_name || ' ' || defendants.last_name) ILIKE :term " +
             "OR lower(defendants.first_name || ' ' || defendants.middle_name || ' ' || defendants.last_name) ILIKE :term"
    },
    advocate_name: {
      joins: { advocate: :user },
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

  def search(*options, term, state)
    raise 'Invalid search option' if (options - QUERY_MAPPINGS_FOR_SEARCH.keys).any?

    sql = options.inject([]) { |r, o| r << "(#{QUERY_MAPPINGS_FOR_SEARCH[o][:query]})" }.join(' OR ')
    relation = options.inject(all) { |r, o| r = r.joins(QUERY_MAPPINGS_FOR_SEARCH[o][:joins]) }

    # TODO - to be removed
    # relation.where(sql, term: "%#{term.downcase}%").where(state: Claims::StateMachine.dashboard_displayable_states).uniq
    relation.where(sql, term: "%#{term.downcase}%").where(state: states).uniq
  end
end
