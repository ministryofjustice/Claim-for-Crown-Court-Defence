Given(/^a claim with messages exists that I have been assigned to$/) do
  @case_worker = CaseWorker.first
  @claim = create(:submitted_claim)
  @messages = create_list(:message, 5, claim_id: @claim.id)
  @messages.each do |message|
    message.sender_id = create(:advocate).user
  end
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

  save_and_open_page

  within '#messages' do
    fill_in 'message_body', with: 'Lorem'
    click_on 'Post'
  end
end

Then(/^I should see my message at the bottom of the message list$/) do
  within '#messages' do
    within '.messages-list' do
      li = page.last(:css, 'li')
      expect(li).to have_content('Lorem')
    end
  end
end

Given(/^I have a submitted claim with messages$/) do
  @claim = create(:submitted_claim, advocate_id: Advocate.first.id)
  @messages = create_list(:message, 5, claim_id: @claim.id)
end
