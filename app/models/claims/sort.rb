module Claims::Sort
  META_SORT_COLUMNS = %w[advocate amount_assessed case_type total_inc_vat last_submitted_at].freeze

  def sortable_columns
    column_names + META_SORT_COLUMNS
  end

  def sortable_by?(column)
    sortable_columns.include?(column)
  end

  def sort(column, direction)
    raise 'Invalid column' unless sortable_by?(column)
    raise 'Invalid sort direction' unless %( asc desc ).include?(direction)

    if META_SORT_COLUMNS.include?(column)
      send("sort_#{column}", direction)
    else
      order(column => direction)
    end
  end

  private

  # NOTE:
  # since searching occurs before sorting and searching calls a uniq/distinct
  # we need to explcitly select values being ordered by to avoid Invalid SQL
  #

  def sort_nulls_by(direction)
    "NULLS #{direction == 'asc' ? 'FIRST' : 'LAST'}"
  end

  def sort_field_by(field, direction)
    "#{field} #{direction.upcase}"
  end

  def sort_field_with_nulls(field, direction)
    "#{sort_field_by(field, direction)} #{sort_nulls_by(direction)}, id desc"
  end

  def sort_last_submitted_at(direction)
    order(sort_field_with_nulls('last_submitted_at', direction))
  end

  def sort_advocate(direction)
    select('claims.*, ("users"."last_name" || \', \' || "users"."first_name") AS user_name')
      .joins(external_user: :user)
      .order(sort_field_by('user_name', direction))
      .order(sort_field_by('created_at', direction))
  end

  def sort_case_type(direction)
    select('"claims".*, "case_types"."name"')
      .joins(:case_type)
      .order(sort_field_by('"case_types"."name"', direction))
  end

  def sort_total_inc_vat(direction)
    select('claims.*, (claims.total+claims.vat_amount) AS total_inc_vat')
      .order(sort_field_by('total_inc_vat', direction))
  end

  # NOTE: amount assessed is the most recent determinations' total including vat
  def sort_amount_assessed(direction)
    select('claims.*, (determinations.total + determinations.vat_amount) AS total_inc_vat')
      .joins(:determinations)
      .where('determinations.created_at = (SELECT MAX(d.created_at) FROM ' \
             '"determinations" d WHERE d."claim_id" = "claims"."id")')
      .order(sort_field_by('total_inc_vat', direction))
  end
end
