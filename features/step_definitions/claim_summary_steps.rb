Then(/^the following check your claim details should exist:$/) do |table|
  expect(@claim_summary_page).to be_displayed
  table.hashes.each do |row|
    within @claim_summary_page.find("##{row['section']}") do
      expect(page).to have_content(row['prompt'])
      expect(page).to have_content(row['value'])
    end
  end
end

Then(/^the following check your claim fee details should exist:$/) do |table|
  expect(@claim_summary_page).to be_displayed
  table.hashes.each do |row|
    within @claim_summary_page.find("##{row['section']}") do
      expect(page).to have_content(row['prompt'])
      expect(page).to have_content(row['value'])
    end
  end
end
