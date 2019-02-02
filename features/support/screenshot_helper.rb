module ScreenshotHelper
   # selenium headless chrome solution for full screenshot
  def screenshot_and_open_image
    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(*dimensions)
    file_path = Rails.root.join("tmp/capybara/capybara-screenshot-#{Time.now.utc.iso8601.gsub('-', '').gsub(':', '')}.png").to_s
    save_screenshot(file_path)
    Launchy.open file_path
  end

  def dimensions
    driver = Capybara.current_session.driver
    total_width = driver.execute_script("return document.body.offsetWidth")
    total_height = driver.execute_script("return document.body.scrollHeight")
    return [total_width, total_height]
  end
end

World(ScreenshotHelper)
