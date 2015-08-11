Given(/^I have a claim in draft state$/) do
  @claim = create(:claim, advocate: @advocate)
end

Given(/^I change the claim's case number to "(.*?)"$/) do |case_number|
  visit edit_advocates_claim_path(@claim)
  fill_in 'claim_case_number', with: case_number
  click_on 'Save to drafts'
end

Then(/^I should see the case number change "(.*?)" reflected in the history$/) do |arg1|
  @claim.reload
  within '#claim-history' do
    within 'table' do
      within all('tr').first do
        expect(page).to have_content(@claim.versions.last.created_at.strftime(Settings.date_time_format))
        expect(page).to have_content('Update')
        expect(page).to have_content('Advocate')
        expect(page).to have_content(/Changed "Case number" from ".+" to "#{@claim.case_number}"/)
      end
    end
  end
end

Given(/^I submit the claim$/) do
  visit edit_advocates_claim_path(@claim)
  click_on 'Submit to LAA'
end

Then(/^I should see the state change to submitted reflected in the history$/) do
  @claim.reload
  within '#claim-history' do
    within 'table' do
      within all('tr').first do
        expect(page).to have_content(@claim.versions.last.created_at.strftime(Settings.date_time_format))
        expect(page).to have_content('State change')
        expect(page).to have_content('Advocate')
        expect(page).to have_content(/Changed "State" from "draft" to "submitted"/)
      end
    end
  end
end

When(/^I visit the claim's case worker detail page$/) do
  visit case_workers_claim_path(@claim)
end

Given(/^I have been allocated a claim$/) do
  @claim = create(:allocated_claim)
  @case_worker.claims << @claim
end

When(/^I mark the claim paid in full$/) do
  select 'Paid in full', from: 'claim_state_for_form'
  fill_in 'claim_assessment_attributes_fees', with: '100.00'
  click_on 'Update'
end

Then(/^I should see the state change to paid in full reflected in the history$/) do
  @claim.reload
  within '#claim-history' do
    within 'table' do
      within all('tr').first do
        expect(page).to have_content(@claim.versions.last.created_at.strftime(Settings.date_time_format))
        expect(page).to have_content('State change')
        expect(page).to have_content('Caseworker')
        expect(page).to have_content(/Changed "State" from "allocated" to "paid"/)
      end
    end
  end
end
