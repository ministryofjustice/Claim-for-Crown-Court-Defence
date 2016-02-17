Given(/^a claim with messages exists that I have been assigned to$/) do
  @case_worker = CaseWorker.first
  @claim = create(:allocated_claim)
  @messages = create_list(:message, 5, claim_id: @claim.id)
  @messages.each { |m| m.update_column(:sender_id, create(:external_user, :advocate).user.id) }
  @claim.case_workers << @case_worker
end

Then(/^I should see the messages for that claim in chronological order$/) do
  message_dom_ids = @messages.sort_by(&:created_at).map { |m| "message_#{m.id}" }
  expect(page.body).to match(/.*#{message_dom_ids.join('.*')}.*/m)
end

When(/^I leave a message$/) do
  within '#panel1' do
    fill_in 'message_body', with: 'Lorem'
    click_on 'Send'
  end
end

Then(/^I should see my message at the bottom of the message list$/) do
  within '#panel1' do
    expect(all('.message-body').last || find('.message-body')).to have_content(/Lorem/)
  end
end

Given(/^I have a submitted claim with messages$/) do
  @claim = create(:submitted_claim, external_user_id: ExternalUser.first.id)
  @messages = create_list(:message, 5, claim_id: @claim.id)
  @messages.each { |m| m.update_column(:sender_id, create(:external_user, :advocate).user.id) }
end


When(/^I edit the claim and save to draft$/) do
  claim = Claim::BaseClaim.last
  visit "/external_users/claims/#{claim.id}/edit"
  click_on 'Save to drafts'
end

Then(/^I should not see any dates in the message history field$/) do
  expect(page.all('div.event-date').count).to eq 0
end

Then(/^I should see 'no messages found' in the claim history$/) do
  expect(page).to have_content('No messages found')
end

Then(/^I (.*?) see the redetermination button$/) do | radio_button_expectation |
  case radio_button_expectation
    when 'should not'
      within('.messages-container') do
        expect(page).to_not have_content('Apply for redetermination')
      end
    when 'should'
      within('.messages-container') do
        expect(page).to have_content('Apply for redetermination')
      end
  end
end

Then(/^I (.*?) see the request written reason button$/) do | radio_button_expectation |
  case radio_button_expectation
    when 'should not'
      within('.messages-container') do
        expect(page).to_not have_content('Request written reasons')
      end
    when 'should'
      within('.messages-container') do
        expect(page).to have_content('Request written reasons')
      end
  end
end

Then(/^I (.*?) see the controls to send messages$/) do | msg_control_expectation |

  case msg_control_expectation
    when 'should not'
      within('.messages-container') do
        expect(page).to_not have_css('.js-test-send-buttons')
      end
    when 'should'
      within('.messages-container') do
        expect(page).to have_css('.js-test-send-buttons')
      end
  end
end

When(/^click on (.*?) option$/) do | radio_button|
  within('.messages-container') do
    choose radio_button
  end
end

Then(/^I can send a message$/) do
  within '#panel1' do
    fill_in 'message_body', with: 'Lorem'
    click_on 'Send'
  end
  wait_for_ajax
end

When(/^I expand the accordion$/) do
  within('#claim-accordion') do
    page.find('h2', text: 'Messages').click
  end
end
