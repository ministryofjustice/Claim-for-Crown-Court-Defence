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
    # error_attribute = attribute if error_attribute.nil?
    set_value(record, attribute, value)
    record.valid?
    expect(no_error_for(record, attribute)).to be true
    # expect(record.errors.keys).not_to include(error_attribute)
  end

  def set_value(record, attribute, value)
    setter_method = "#{attribute}=".to_sym
    record.__send__(setter_method, value)
  end

  def no_error_for(record, attribute)
    return true unless record.errors.keys.include?(attribute)
    return true if record.errors[attribute].empty?
    return false
  end

  def with_env(env)
    @original_env = ENV['ENV']
    ENV['ENV'] = env
    yield
  ensure
    ENV['ENV'] = @original_env
  end

  def scheme_date_for(text)
    case text&.downcase&.strip
      when 'scheme 12' then
        Settings.clar_release_date.strftime
      when 'scheme 11' then
        Settings.agfs_scheme_11_release_date.strftime
      when 'scheme 10' || 'post agfs reform' then
        Settings.agfs_fee_reform_release_date.strftime
      when 'scheme 9' || 'pre agfs reform' then
        '2016-01-01'
      when 'lgfs' then
        '2016-04-01'
      else
        '2016-01-01'
    end
  end
end
