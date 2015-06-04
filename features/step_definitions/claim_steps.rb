When(/^a claim exists that belongs to the(?: (\d+)\w+)? advocate$/) do |cardinality|
  card = cardinality.nil? ? 0 : cardinality.to_i - 1
  @claim = create(:claim, advocate: @advocates[card])
end

Then(/^an anonymous user cannot access the claim$/) do
  click 'Sign out' rescue nil
  visit advocates_claim_url(@claim)
  expect(page.current_url).to eq(root_url)
  expect(page).to have_content(/must be signed in/i)
end

Then(/^(?:the|that) (?:advocate(?: admin)?) can (?:access|manage) the claim$/) do
  visit edit_advocates_claim_url(@claim)
  expect(page).to have_content(/Edit claim/)
end

Then(/^(?:the|that) (?:advocate(?: admin)?) cannot (?:access|manage) the claim$/) do
  visit edit_advocates_claim_url(@claim)
  expect(page).not_to have_content(/Edit claim/)
end

Then(/^the case worker can access all claims$/) do
  expected_copy = 'Edit claim'
  Claim.all.each do |claim|
    visit edit_advocates_claim_url(claim)
    expect(page).to have_content(/#{expected_copy}/)
  end
end
