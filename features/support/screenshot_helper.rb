module ScreenshotHelper
  def save_and_open_screenhot
    sleep 3 # give js time to render
    file_path = Rails.root.join("tmp/capybara/capybara-screenshot-#{Time.now.utc.iso8601.gsub('-', '').gsub(':', '')}.png").to_s
    page.save_screenshot(file_path, full: true)
    Launchy.open file_path
  end
end

World(ScreenshotHelper)
