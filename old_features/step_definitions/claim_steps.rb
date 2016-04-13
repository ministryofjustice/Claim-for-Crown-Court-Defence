When(/^a claim exists that belongs to the(?: (\d+)\w+)? advocate$/) do |cardinality|
  card = cardinality.nil? ? 0 : cardinality.to_i - 1
  @claim = create(:claim, external_user: @advocates[card])
end

Then(/^an anonymous user cannot access the claim$/) do
  click 'Sign out' rescue nil
  visit external_users_claim_url(@claim)
  expect(page).to have_content(/Must be signed in as an external user/i)
end

Then(/^(?:the|that) (?:advocate(?: admin)?) can (?:access|manage) the claim$/) do
  visit edit_advocates_claim_path(@claim)
  expect(page).to have_content(/Edit (advocate )+claim/)
end

Then(/^(?:the|that) (?:advocate(?: admin)?) cannot (?:access|manage) the claim$/) do
  visit edit_advocates_claim_path(@claim)
  expect(page).to have_content(/unauthorised/i)
end

Then(/^the case worker can access all claims$/) do
  Claim::BaseClaim.all.each do |claim|
    visit case_workers_claim_path(claim)
    expect(page).to have_content(/#{claim.case_number}/)
  end
end
