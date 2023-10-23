javascript_data = ""

Given("I have created test claims for {string}") do |date|
  split_date = date.split("/")
  travel_to(Time.zone.local(split_date[2].to_i, split_date[1].to_i, split_date[0].to_i)) do
    claim_one = create(:advocate_final_claim)
    claim_one.update_attribute(:state, 'submitted')
    claim_one.update_attribute(:last_submitted_at, Time.current)

    claim_two = create(:litigator_final_claim)
    claim_two.update_attribute(:state, 'submitted')
    claim_two.update_attribute(:last_submitted_at, Time.current)

  end
end

And("I enter the From date {string}") do |date|
  split_date = date.split("/")
  find('#_date_from_3i').set(split_date[0])
  find('#_date_from_2i').set(split_date[1])
  find('#_date_from_1i').set(split_date[2])
end

And("I enter the To date {string}") do |date|
  split_date = date.split("/")
  find('#_date_to_3i').set(split_date[0])
  find('#_date_to_2i').set(split_date[1])
  find('#_date_to_1i').set(split_date[2])
end

And("I click Update") do
  javascript_data = find('#total-claims-chart').sibling('script', visible: false).text(:all)

  find("#date_submit").click
end

Then("the Javascript variable createChart should change") do
  new_javascript_data = find('#total-claims-chart').sibling('script', visible: false).text(:all)
  expect(new_javascript_data).not_to eq(javascript_data)
end
