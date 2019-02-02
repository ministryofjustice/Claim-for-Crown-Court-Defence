module WaitForAjax
  # Do not use Timeout
  # https://medium.com/doctolib/hunting-flaky-tests-2-waiting-for-ajax-bd76d79d9ee9
  # https://medium.com/@adamhooper/in-ruby-dont-use-timeout-77d9d4e5a001
  #
  def wait_for_ajax(wait_time: Capybara.default_max_wait_time)
    max_time = Capybara::Helpers.monotonic_time + wait_time
    while Capybara::Helpers.monotonic_time < max_time
      finished = finished_all_ajax_requests?
      finished ? break : sleep(0.1)
    end
    raise 'wait_for_ajax timeout' unless finished
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

World(WaitForAjax)
