# NOTE: shared steps
#       Steps that are applicable for Your Claims, Archived, Outstanding and Authorised claims list, at least

Then(/^I should see all claims$/) do
  save_and_open_page
  @claims.each do |claim|
    expect(page).to have_selector("#claim_#{claim.id}")
  end
end
