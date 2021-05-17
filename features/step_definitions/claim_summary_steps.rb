Then(/^the following check your claim details should exist:$/) do |table|
  expect(@claim_summary_page).to be_displayed
  table.hashes.each do |row|
    within @claim_summary_page.find("##{row['section']}") do
      expect(page).to have_content(row['prompt'])
      expect(page).to have_content(row['value'])
    end
  end
end

Then(/^the following check your claim fee details should (not )?exist:$/) do |negate, table|
  expect(@claim_summary_page).to be_displayed
  table.hashes.each do |row|
    within @claim_summary_page.find("##{row['section']}") do
      if negate
        expect(page).to_not have_content(row['prompt'])
      else
        expect(page).to have_content(row['prompt'])
        expect(page).to have_content(row['value'])
      end
    end
  end
end

Then("I should be in the providers claim summary page") do
  expect(@external_user_claim_show_page).to be_displayed
end

When("I edit the claim's case details") do
  @claim_summary_page.change_case_details.click
end

When("I edit the claim's defendants") do
  @claim_summary_page.change_defendants.click
end

When("I edit the claim's expenses") do
  @claim_summary_page.change_expenses.click
end

When("I edit the claim's supporting evidence") do
  @claim_summary_page.change_supporting_evidence.click
end
