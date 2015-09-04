module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      active = page.evaluate_script('jQuery.active')
      until active == 0
        active = page.evaluate_script('jQuery.active')
      end
    end
  end
end

World(WaitForAjax)
