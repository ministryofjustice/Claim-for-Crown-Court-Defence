# frozen_string_literal: true

require 'selenium/webdriver'

# Chrome reports a node from a replaced document as UnknownError, which Capybara won't retry
module StaleNodeReclassifier
  STALE_NODE_MESSAGE = 'does not belong to the document'

  def execute(*, **, &)
    super
  rescue Selenium::WebDriver::Error::UnknownError => e
    raise unless e.message.include?(STALE_NODE_MESSAGE)

    raise Selenium::WebDriver::Error::StaleElementReferenceError, e.message
  end
end

Selenium::WebDriver::Remote::Bridge.prepend(StaleNodeReclassifier)
