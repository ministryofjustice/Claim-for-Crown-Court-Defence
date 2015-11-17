Given(/^I have (\d+) (.*?) claim$/) do |number,state|
  if number.to_i == 1
    @claim = create_list("#{state}_claim".to_sym, number.to_i, advocate: @advocate)
  else
    @claims = create_list("#{state}_claim".to_sym, number.to_i, advocate: @advocate)
  end
end
