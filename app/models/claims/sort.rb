module Claims::Sort

  META_SORT_COLUMNS = %w( advocate defendants amount_assessed messages submitted_at case_type )

  def sort(column, direction)
    sort_columns = column_names + META_SORT_COLUMNS

    raise 'Invalid column' unless sort_columns.include?(column)
    raise 'Invalid sort direction' unless %( asc desc ).include?(direction)

    case column
      when 'advocate'
        joins(advocate: :user).order("users.last_name #{direction}, users.first_name #{direction}")
      when 'defendants'
        includes(:defendants).order("defendants.last_name #{direction}, defendants.first_name #{direction}")
      when 'submitted_at'
        order("last_submitted_at #{direction}")
      when 'case_type'
        joins(:case_type).order("case_types.name #{direction}")
      when 'amount_assessed'
        joins(:determinations).order("determinations.total #{direction}")
      when 'messages'
        select('claims.*, COUNT(messages.id) AS messages_count').joins(:messages).group('claims.id').order("messages_count #{direction}")
      else
        order(column => direction)
    end
  end
end
