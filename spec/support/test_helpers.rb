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
end