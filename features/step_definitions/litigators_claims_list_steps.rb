When(/^I visit the litigators dashboard$/) do
  visit external_users_claims_path
end

Given(/^my firm has claims$/) do
  # create a firm with two litigator admins
  # make logged in litigator a member of that firm
  firm = create(:provider, :lgfs)
  litigator1 = create(:external_user, :litigator_and_admin, provider: firm)
  litigator2 = create(:external_user, :litigator_and_admin, provider: firm)
  @litigator.provider = firm
  @litigator.save!

  # create claims created by the first and second litigator
  @claims = create_list(:litigator_claim, 3, creator: litigator1)
  @claims.concat(create_list(:litigator_claim, 2, creator: litigator2))
end

Then(/^I should see all my firm's claims$/) do
  @claims.each do |claim|
    expect(page).to have_selector("#claim_litigator_claim_#{claim.id}")
  end
end
