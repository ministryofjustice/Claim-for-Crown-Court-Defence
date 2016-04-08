module TestHelpers

  # Methods here are exposed globally to all rspec tests, but do not abuse this.
  # Do not require external dependencies in this file, and only use it when the
  # methods are going to be used in a lot of specs.
  #
  # Requiring heavyweight dependencies from this file will add to the boot time of
  # the test suite on EVERY test run.
  # Instead, consider making a separate helper file and requiring it from the spec
  # file or files that actually need it.

  def expense_attributes_for(expense_type, date: nil)
    {
      expense_type_id: expense_type.id,
      location: 'London',
      amount: 40,
      reason_id: 2,
      distance: 5,
      mileage_rate_id: 1
    }.tap { |h| date ? h.merge!(date: date) : h.merge!(date_dd: '01', date_mm: '02', date_yyyy: '2015') }
  end

end