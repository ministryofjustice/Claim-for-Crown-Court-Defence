class CertificationPage < SitePrism::Page
  set_url "/external_users/claims/{id}/certification/new"

  element :attended_main_hearing, "label.i-attended-the-main-hearing-1st-day-of-trial"
  element :certify_and_submit_claim, "div.certification > div.button-holder > input"
end
