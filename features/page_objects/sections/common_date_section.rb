class CommonDateSection < SitePrism::Section
  include DateHelper
  element :day,   'div.form-date > div.form-group-day > input'
  element :month, 'div.form-date > div.form-group-month > input'
  element :year,  'div.form-date > div.form-group-year > input'
end
