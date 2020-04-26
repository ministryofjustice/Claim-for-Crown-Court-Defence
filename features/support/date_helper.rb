require Rails.root.join('spec', 'support', 'scheme_date_helpers')

module DateHelper
  include SchemeDateHelpers

  def set_date(date_string)
    date = Time.parse(date_string)
    self.day.set date.day.to_s
    self.month.set date.month.to_s
    self.year.set date.year.to_s
  end

  def set_invalid_date
    self.day.set '1'
  end
end

World(DateHelper)
