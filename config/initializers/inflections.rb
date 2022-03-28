# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  # inflect.plural /^(ox)$/i, '\1en'
  # inflect.singular /^(ox)en/i, '\1'
  # inflect.irregular 'person', 'people'
  # inflect.uncountable %w( fish sheep )
  inflect.irregular 'date_attended', 'dates_attended'
  inflect.irregular 'claim was', 'claims were'
  inflect.acronym 'CPS'
  inflect.acronym 'AF1'
  inflect.acronym 'AF2'
  inflect.acronym 'LF1'
  inflect.acronym 'LF2'
  inflect.human(/af1_lf1_processed_by/, "af1/lf1 processed by")
  inflect.acronym 'API'
  inflect.acronym 'XML'
  inflect.acronym 'MI'
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
