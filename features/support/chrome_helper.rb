module ChromeHelper
  def switch_to_chrome_window
    switch_to_window(Capybara.current_session.current_window) if Capybara.current_driver == :chrome
  end
end

World(ChromeHelper)
