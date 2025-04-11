module BetaHelper
  def beta_test_partial(partial)
    return partial if session['beta_testing'] == 'disabled'

    "#{partial}_beta"
  end

  def beta_test_link
    govuk_link_to(beta_test_link_label, beta_test_link_url, class: beta_test_link_class)
  end

  private

  def beta_test_link_label
    session['beta_testing'] == 'disabled' ? 'Change to new layout' : 'Change back to old layout'
  end

  def beta_test_link_url = session['beta_testing'] == 'disabled' ? beta_enable_path : beta_disable_path

  def beta_test_link_class
    if session['beta_testing'] == 'disabled'
      ['govuk-button']
    else
      ['govuk-button', 'govuk-button--secondary']
    end
  end
end
