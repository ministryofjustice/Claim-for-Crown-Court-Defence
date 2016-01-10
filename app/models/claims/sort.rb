module Claims::Sort

  META_SORT_COLUMNS = %w( advocate defendants amount_assessed case_type )

  def sortable_columns
    column_names + META_SORT_COLUMNS
  end

  def sortable_by?(column)
    sortable_columns.include?(column)
  end

  def sort(column, direction)

    raise 'Invalid column' unless sortable_by?(column)
    raise 'Invalid sort direction' unless %( asc desc ).include?(direction)

    case column
      when 'advocate'
        sort_advocates(direction)
      when 'defendants'
        sort_defendants(direction)
      when 'submitted_at'
        sort_submitted_at(direction)
      when 'case_type'
        sort_case_type(direction)
      when 'amount_assessed'
        sort_amount_assessed(direction)
      # disabled til functional
      # when 'messages'
        # sort_messages(direction)
      else
        order(column => direction)
    end
  end

  private

  def sort_advocates(direction)
    joins(advocate: :user).order("users.last_name #{direction}, users.first_name #{direction}")
  end

  def sort_defendants(direction)
    includes(:defendants).order("defendants.last_name #{direction}, defendants.first_name #{direction}")
  end

  def sort_case_type(direction)
    joins(:case_type).order("case_types.name #{direction}")
  end

  def sort_amount_assessed(direction)
    joins(:determinations).order("determinations.total #{direction}")
  end

  def sort_messages(direction)
    # TODO: sort_messages - broken

    # seems to work but breaks claim carousel
    joins(:messages).group(claims: :id).order("count(messages.*) #{direction}")

    # does not work
    # select('claims.id, COUNT(messages.*) AS messages_count').joins(:messages).group('claims.id').order("messages_count #{direction}")
  end
end
