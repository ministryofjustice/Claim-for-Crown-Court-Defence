require File.dirname(__FILE__) + '/database_housekeeping'
require_relative 'scheme_date_helpers'

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
  include SchemeDateHelpers

  def expect_invalid_attribute_with_message(record, attribute, value, message)
    error_attribute = attribute if error_attribute.nil?
    set_value(record, attribute, value)
    expect(record).not_to be_valid
    expect(record.errors[error_attribute]).to include(message)
  end

  def expect_valid_attribute(record, attribute, value)
    set_value(record, attribute, value)
    record.valid?
    expect(record.errors[attribute]).to be_blank
  end

  def set_value(record, attribute, value)
    setter_method = :"#{attribute}="
    record.__send__(setter_method, value)
  end

  def with_env(env)
    @original_env = ENV.fetch('ENV', nil)
    ENV['ENV'] = env
    yield
  ensure
    ENV['ENV'] = @original_env
  end
end
