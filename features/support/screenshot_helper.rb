module ScreenshotHelper
  # convenience override of default method of the same name to specify
  # full path and timestamped file name and get full screenshot.
  #
  def save_and_open_screenshot(wait: Capybara.default_max_wait_time)
    sleep wait # give js time to render
    file_path = Rails.root.join("tmp/capybara/capybara-screenshot-#{Time.now.utc.iso8601.gsub('-', '').gsub(':', '')}.png").to_s
    page.save_screenshot(file_path, full: true)
    Launchy.open file_path
  end
end

World(ScreenshotHelper)
