Given(/^I have (\d+) (.*?) claim$/) do |number,state|
  if number.to_i == 1
    @claim = create("#{state}_claim".to_sym,  external_user: @advocate)
  else
    @claims = create_list("#{state}_claim".to_sym, number.to_i, external_user: @advocate)
  end
end

Then(/^the claim should be in the "(.*?)" state$/) do |state|
  @claim.reload
  expect(@claim.state).to eq(state)
end

Then(/the claim count should show (\d+)/) do | quantity |
  within '.claim-count' do
    expect(page).to have_content(/Number of claims: #{quantity}?/)
  end
end
