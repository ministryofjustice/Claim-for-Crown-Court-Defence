class LondonRatesSection < SitePrism::Section
  element :radio, 'label'
end

class LondonRatesRadioSection < SitePrism::Section
  sections :london_rates_options, LondonRatesSection, '.govuk-radios__item'
  element :yes, "label[for='claim-london-rates-apply-true-field']"
  element :no, "label[for='claim-london-rates-apply-field']"
end
