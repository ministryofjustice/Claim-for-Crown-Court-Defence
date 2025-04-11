module BetaHelper
  def beta_test_partial(partial)
    return "#{partial}_beta" if session['beta_testing'] == 'true'

    partial
  end

  def beta_test_link
    govuk_link_to(beta_test_link_label, request.params.merge(beta_testing: beta_test_link_param))
  end

  private

  def beta_test_link_label = session['beta_testing'] == 'true' ? 'Disable beta view' : 'Enable beta view'
  def beta_test_link_param = session['beta_testing'] == 'true' ? 'false' : 'true'
end
