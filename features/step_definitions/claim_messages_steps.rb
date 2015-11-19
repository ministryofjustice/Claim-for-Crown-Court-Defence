Given(/^a claim with messages exists that I have been assigned to$/) do
  @case_worker = CaseWorker.first
  @claim = create(:submitted_claim)
  @messages = create_list(:message, 5, claim_id: @claim.id)
  @messages.each { |m| m.update_column(:sender_id, create(:advocate).user.id) }
  @claim.case_workers << @case_worker
end

When(/^I visit that claim's "(.*?)" detail page$/) do |namespace|
  case namespace
    when 'advocate'
      visit advocates_claim_path(@claim)
    when 'case worker'
      visit case_workers_claim_path(@claim)
  end
end

Then(/^I should see the messages for that claim in chronological order$/) do
  message_dom_ids = @messages.sort_by(&:created_at).map { |m| "message_#{m.id}" }
  expect(page.body).to match(/.*#{message_dom_ids.join('.*')}.*/m)
end

When(/^I leave a message$/) do
  within '#messages' do
    fill_in 'message_body', with: 'Lorem'
    click_on 'Send'
  end
end

Then(/^I should see my message at the bottom of the message list$/) do
  within '#messages' do
    within '.messages-list' do
      message_body = all('.message-body').last
      expect(message_body).to have_content(/Lorem/)
    end
  end
end

Given(/^I have a submitted claim with messages$/) do
  @claim = create(:submitted_claim, advocate_id: Advocate.first.id)
  @messages = create_list(:message, 5, claim_id: @claim.id)
  @messages.each { |m| m.update_column(:sender_id, create(:advocate).user.id) }
end

When(/^I edit the claim and save to draft$/) do
  claim = Claim.last
  visit "/advocates/claims/#{claim.id}/edit"
  click_on 'Save to drafts'
end

Then(/^I should not see any dates in the message history field$/) do
  expect(page.all('div.event-date').count).to eq 0
end

Then(/^I should see 'no messages found' in the claim history$/) do
  expect(page).to have_content('No messages found')
end