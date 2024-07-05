class LondonFeesSection < SitePrism::Section
  element :radio, 'label'
end

class LondonFeesRadioSection < SitePrism::Section
  sections :london_fees_options, LondonFeesSection, '.govuk-radios__item'
end
