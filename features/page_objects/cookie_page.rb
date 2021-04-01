class CookiePage < BasePage
  section :banner, '.govuk-cookie-banner' do
    section :message, '.govuk-cookie-banner__message' do
      element :accept_cookies, '.govuk-button-group a[href="?usage_opt_in=true&show_confirmation=true"]'
      element :reject_cookies, '.govuk-button-group a[href="?usage_opt_in=false&show_confirmation=true"]'
      element :view_cookies, '.govuk-button-group a[href="/help/cookies"]'
    end
    section :confirmation, '.govuk-cookie-banner__confirmation' do
      element :hide, '.govuk-button-group a[href="?show_confirmation=false"]'
    end
  end

  element :success_notification, '.govuk-notification-banner--success'
  section :form, 'form[action="/help/cookies"]' do
    element :accept_cookies, '#cookies-analytics-true-field'
    element :reject_cookies, '#cookies-analytics-false-field'
    element :submit, 'input[value="Save changes"]'
  end
end
