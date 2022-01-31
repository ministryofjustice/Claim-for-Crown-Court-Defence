class GovukDateSection < SitePrism::Section
  include DateHelper
  element :day, 'div.govuk-date-input div.govuk-date-input__item:nth-child(1) input'
  element :month, 'div.govuk-date-input div.govuk-date-input__item:nth-child(2) input'
  element :year, 'div.govuk-date-input div.govuk-date-input__item:nth-child(3) input'
end
