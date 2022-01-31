# Mixin for parsing govuk_date_fields parameters prior to handling by
# rails.
#
# The govuk_date_fields helper uses the rails default multiparameters
# for dates:
# ```
# my_date_attribute(3i), my_date_attribute(2i), my_date_attribute(1i).
# ````
# These are parsed by rails and raise an `ActiveRecord::MultiparameterAssignmentErrors`
# if the parameters are invalid for a date (e.g. 32-01-2021).
# This would then result in a 500 unless handled so we parse the date
# from the params first and clean invalid date part values before rails
# can raise this error.
#
module MultiparameterAttributeCleaner
  extend ActiveSupport::Concern

  def clean_multiparameter_dates
    return unless params
    find_and_clean_dates(params)
  end

  private

  def find_and_clean_dates(parameters)
    parameters.each_pair do |k, v|
      if v.respond_to?(:each_pair)
        find_and_clean_dates(v)
      elsif k.to_s.include?('(3i)')
        parameters[k] = '' unless valid_day_param?(v)
      elsif k.to_s.include?('(2i)')
        parameters[k] = '' unless valid_month_param?(v)
      end
    end
  end

  def valid_day_param?(val)
    val.blank? || (1..31).cover?(val.to_i)
  end

  def valid_month_param?(val)
    val.blank? || (1..12).cover?(val.to_i)
  end
end
