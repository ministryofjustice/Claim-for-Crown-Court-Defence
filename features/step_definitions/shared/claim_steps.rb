Given(/^I have (\d+) (.*?) claim$/) do |number,state|
  if number.to_i == 1
    @claim = create("#{state}_claim".to_sym,  advocate: @advocate)
  else
    @claims = create_list("#{state}_claim".to_sym, number.to_i, advocate: @advocate)
  end
end

Then(/^the claim should be in the "(.*?)" state$/) do |state|
  @claim.reload
  expect(@claim.state).to eq(state)
end
