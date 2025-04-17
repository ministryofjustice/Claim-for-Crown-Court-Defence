module BetaHelper
  def beta_test_partial(partial)
    return "#{partial}_beta" if session['disable_beta_testing'] == 'false'

    partial
  end

  def beta_test_link
    govuk_link_to(
      beta_test_link_label,
      request.params.merge(disable_beta_testing: beta_test_link_param), class: beta_test_link_class
    )
  end

  private

  def beta_test_link_label
    session['disable_beta_testing'] == 'false' ? 'Change back to old layout' : 'Change to new layout'
  end

  def beta_test_link_param
    session['disable_beta_testing'] == 'false' ? 'true' : 'false'
  end

  def beta_test_link_class
    if session['disable_beta_testing'] == 'false'
      ['govuk-button']
    else
      ['govuk-button', 'govuk-button--secondary']
    end
  end
end
