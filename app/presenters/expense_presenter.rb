class ExpensePresenter < BasePresenter
  presents :expense

  def amount
    h.number_to_currency(expense.amount.to_f)
  end

  def vat_amount
    h.number_to_currency(expense.vat_amount.to_f)
  end

  def gross_amount
    h.number_to_currency(expense.vat_amount.to_f + expense.amount.to_f)
  end

  def total
    h.number_to_currency(expense.amount.to_f + expense.vat_amount.to_f)
  end

  def distance
    h.number_with_precision(expense.distance, precision: 2, strip_insignificant_zeros: true)
  end

  def calculated_distance
    return unless expense.calculated_distance.present?
    h.number_with_precision(expense.calculated_distance, precision: 2, strip_insignificant_zeros: true)
  end

  def pretty_calculated_distance
    return 'n/a' unless calculated_distance.present?
    "#{calculated_distance} #{t('distance.unit', count: calculated_distance)}"
  end

  def location_postcode
    @location_postcode ||=
      Establishment.find_by(name: expense.location)&.postcode
  end

  def location_with_postcode
    return "#{expense.location} (#{location_postcode})" if location_postcode
    expense.location
  end

  def hours
    h.number_with_precision(expense.hours, precision: 2, strip_insignificant_zeros: true)
  end

  def name
    if expense.expense_type.blank?
      'Not selected'
    else
      expense.expense_type.name
    end
  end

  def pretty_date
    expense.date.nil? ? 'Date not set' : expense.date.strftime(Settings.date_format)
  end

  def display_reason_text_css
    expense.expense_reason_other? ? 'inline-block' : 'none'
  end

  def reason
    expense.displayable_reason_text || 'Not provided'
  end

  def mileage_rate
    expense.mileage_rate&.name || 'n/a'
  end
end
