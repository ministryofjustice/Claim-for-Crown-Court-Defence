class DeterminationPresenter < BasePresenter

  presents :version

  def event
    version.event
  end

  def timestamp
    " - #{version.created_at.strftime('%H:%M')}"
  end

  def itemise
    items.each do |attribute, new_value|
      yield attribute, new_value
    end
  end

  def items
    {
      'Fees' => changes['fees'].last,
      'Expenses' => changes['expenses'].last,
      'Total (ex VAT)' => changes['total'].last,
      'VAT' => changes['vat_amount'].last,
      'Total (inc VAT)' => total_inc_vat
    }
  end

  def changes
    {
      'fees' => [0.00, 0.00],
      'expenses' => [0.00, 0.00],
      'total' => [0.00, 0.00],
      'vat_amount' => [0.00, 0.00]
    }.merge(changeset)
  end

  def total_inc_vat
    changes['vat_amount'].last + changes['total'].last
  end

end
