Then(/^I should( not)? see the archive button$/) do |negation|
  does = negation.nil? ? 'to' : negation.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  within '#content' do
    expect(page).method(does).call have_selector('a', text: /\AArchive\z/)
  end
end

When(/^I click on the archive button$/) do
  within '#content' do
    click_on 'Archive'
  end
end

Then(/^the claim should be archived$/) do
  claim = Claim::BaseClaim.last
  expect(claim).to be_archived_pending_delete
end

Then(/^I should( not)? see the claim on the archive page$/) do |negation|
  claim = Claim::BaseClaim.last
  does = negation.nil? ? 'to' : negation.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  visit archived_external_users_claims_path
  expect(page).method(does).call have_content(claim.case_number)
end
