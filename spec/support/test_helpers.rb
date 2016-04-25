require File.dirname(__FILE__) + '/database_housekeeping'

module TestHelpers
  # Methods here are exposed globally to all rspec tests, but do not abuse this.
  # Do not require external dependencies in this file, and only use it when the
  # methods are going to be used in a lot of specs.
  #
  # Requiring heavyweight dependencies from this file will add to the boot time of
  # the test suite on EVERY test run.
  # Instead, consider making a separate helper file and requiring it from the spec
  # file or files that actually need it.

  include DatabaseHousekeeping

  def expect_invalid_attribute_with_message(record, attribute, value, message)
    error_attribute = attribute if error_attribute.nil?
    set_value(record, attribute, value)
    expect(record).not_to be_valid
    expect(record.errors[error_attribute]).to include(message)
  end

  def expect_valid_attribute(record, attribute, value)
    # error_attribute = attribute if error_attribute.nil?
    set_value(record, attribute, value)
    record.valid?
    expect(no_error_for(record, attribute)).to be true
    # expect(record.errors.keys).not_to include(error_attribute)
  end

  def set_value(record, attribute, value)
    setter_method = "#{attribute}=".to_sym
    record.__send__(setter_method, value)
    record.form_step = 2
    record.force_validation = true
  end

  def no_error_for(record, attribute)
    return true unless record.errors.keys.include?(attribute)
    return true if record.errors[attribute].empty?
    return false
  end
end