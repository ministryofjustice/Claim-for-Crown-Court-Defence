Then(/^I should( not)? see the archive button$/) do |negation|
  does = negation.nil? ? 'to' : negation.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  within '.main-content' do
    expect(page).method(does).call have_selector('a', text: /\AArchive\z/)
  end
end

When(/^I click on the archive button$/) do
  within '.main-content' do
    click_on 'Archive'
  end
end

Then(/^I should( not)? see the claim on the archive page$/) do |negation|
  claim = Claim.last
  does = negation.nil? ? 'to' : negation.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  visit archived_external_users_claims_path
  expect(page).method(does).call have_content(claim.case_number)
end
