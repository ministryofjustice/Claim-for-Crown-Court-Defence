module WaitForAjax
  # Do not use Timeout
  # https://medium.com/doctolib/hunting-flaky-tests-2-waiting-for-ajax-bd76d79d9ee9
  # https://medium.com/@adamhooper/in-ruby-dont-use-timeout-77d9d4e5a001
  #
  def wait_for_ajax(wait_time: Capybara.default_max_wait_time)
    max_time = Capybara::Helpers.monotonic_time + wait_time
    puts '----'
    while Capybara::Helpers.monotonic_time < max_time
      puts ">> #{max_time - Capybara::Helpers.monotonic_time}"
      finished = finished_all_ajax_requests?
      finished ? break : sleep(0.5)
    end
    raise 'wait_for_ajax timeout' unless finished
  end

  def finished_all_ajax_requests?
    page.evaluate_script(ajax_finished_script)
  end

  def ajax_finished_script
    <<~EOS
    (
      (typeof window.jQuery === 'undefined')
      || (typeof window.jQuery.active === 'undefined')
      || (window.jQuery.active === 0)
    ) && (
          (typeof window.injectedJQueryFromNode === 'undefined')
          || (typeof window.injectedJQueryFromNode.active === 'undefined')
          || (window.injectedJQueryFromNode.active === 0)
          )
    EOS
  end

  # TODO: amend to be smarter in relation to $.debounce JQuery behaviour
  # but for now just using a sleep that exceeds $.debounce milliseconds
  # in JS
  def wait_for_debounce(wait_time: 0.5)
    sleep wait_time
  end
end

World(WaitForAjax)
