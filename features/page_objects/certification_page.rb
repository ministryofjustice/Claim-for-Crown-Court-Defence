class CertificationPage < SitePrism::Page
  set_url "/external_users/claims/{id}/certification/new"

  element :attended_main_hearing, "section.certification > div:nth-of-type(1) > div:nth-of-type(1) > div:nth-of-type(1) div:nth-of-type(1) input"
  element :certify_and_submit_claim, "section.certification > div.button-holder > input"
end
