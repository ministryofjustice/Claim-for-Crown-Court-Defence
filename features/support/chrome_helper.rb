module ChromeHelper
  def switch_to_chrome_window
    switch_to_window(Capybara.current_session.current_window) if ENV['BROWSER'] == 'chrome'
  end
end

World(ChromeHelper)
