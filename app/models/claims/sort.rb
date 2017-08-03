module Claims::Sort
  META_SORT_COLUMNS = %w[advocate amount_assessed case_type total_inc_vat].freeze

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
    when 'last_submitted_at'
      sort_submitted_at(direction)
    when 'advocate'
      sort_advocates(direction)
    when 'case_type'
      sort_case_type(direction)
    when 'total_inc_vat'
      sort_total_inc_vat(direction)
    when 'amount_assessed'
      sort_amount_assessed(direction)
    else
      order(column => direction)
    end
  end

  private

  # NOTE:
  # since searching occurs before sorting and searching calls a uniq/distinct
  # we need to explcitly select values being ordered by to avoid Invalid SQL
  #

  def nulls_at_top_asc(direction)
    'NULLS ' + (direction == 'asc' ? 'FIRST' : 'LAST')
  end

  def sort_submitted_at(direction)
    order("last_submitted_at #{direction} #{nulls_at_top_asc(direction)}, id desc")
  end

  def sort_advocates(direction)
    select('claims.*, ("users"."last_name" || \', \' || "users"."first_name") AS user_name')
      .joins(external_user: :user)
      .order("user_name #{direction}, created_at #{direction}")
  end

  def sort_case_type(direction)
    select('claims.*, "case_types"."name" AS case_type_name')
      .joins(:case_type)
      .order("case_type_name #{direction}")
  end

  def sort_total_inc_vat(direction)
    select('claims.*, (claims.total+claims.vat_amount) AS total_inc_vat').order("total_inc_vat #{direction}")
  end

  # NOTE: amount assessed is the most recent determinations' total including vat
  def sort_amount_assessed(direction)
    select('claims.*, (determinations.total + determinations.vat_amount) AS total_inc_vat')
      .joins(:determinations)
      .where('determinations.created_at = (SELECT MAX(d.created_at) FROM "determinations" d WHERE d."claim_id" = "claims"."id")')
      .order("total_inc_vat #{direction}")
  end
end
