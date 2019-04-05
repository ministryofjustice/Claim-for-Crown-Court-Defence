# helper to capture certain errors and expectation failures
# and retry until timeout reached.
# Idea taken from:
# https://github.com/makandra/spreewald
#
module PatienceHelper
  RETRY_ERRORS = %w[
    Capybara::ElementNotFound
    Spec::Expectations::ExpectationNotMetError
    RSpec::Expectations::ExpectationNotMetError
    Minitest::Assertion
    Capybara::Poltergeist::ClickFailed
    Capybara::ExpectationNotMet
    Selenium::WebDriver::Error::StaleElementReferenceError
    Selenium::WebDriver::Error::NoAlertPresentError
    Selenium::WebDriver::Error::ElementNotVisibleError
    Selenium::WebDriver::Error::NoSuchFrameError
    Selenium::WebDriver::Error::NoAlertPresentError
    Selenium::WebDriver::Error::JavascriptError
    Selenium::WebDriver::Error::UnknownError
    Selenium::WebDriver::Error::NoSuchAlertError
  ]

  class Patiently
    # The sleep period is significant in cases where
    # processing speed may be a cause of intermittent failures
    # (flickers). Too low and it may excerbate the issue.
    SLEEP_PERIOD = 1
    MAX_TRIES = 2

    def call(seconds, &block)
      started = monotonic_time
      tries = 0
      max_time = monotonic_time + seconds
      begin
        tries += 1
        block.call
      rescue Exception => e
        raise e unless retryable_error?(e)
        raise e if (monotonic_time > max_time && tries >= MAX_TRIES)
        sleep(SLEEP_PERIOD)
        raise Capybara::FrozenInTime, "time appears to be frozen, Capybara does not work with libraries which freeze time, consider using time travelling instead" if monotonic_time == started
        retry
      end
    end

    private

    def retryable_error?(e)
      RETRY_ERRORS.include?(e.class.name)
    end

    def monotonic_time
      Capybara::Helpers.monotonic_time
    end
  end

  def patiently(seconds = Capybara.default_max_wait_time, &block)
    if page.driver.wait?
      Patiently.new.call(seconds, &block)
    else
      block.call
    end
  end
end

World(PatienceHelper)
