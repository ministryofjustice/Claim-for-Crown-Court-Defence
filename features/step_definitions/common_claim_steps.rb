When(/^I select the court '(.*?)'$/) do |name|
  @claim_form_page.select_court(name)
end

When(/^I select a case type of '(.*?)'$/) do |name|
  @claim_form_page.select_case_type name
end

When(/^I enter a case number of '(.*?)'$/) do |number|
  @claim_form_page.case_number.set number
end

When(/^I enter (.*?)defendant, representation order and MAAT reference$/) do |scheme_text|
    date = scheme_text.match?('scheme 10') || scheme_text.match?('post agfs reform') ? Settings.agfs_fee_reform_release_date.strftime : "2016-01-01"
    using_wait_time(6) do
      @claim_form_page.wait_for_defendants
      @claim_form_page.defendants.first.first_name.set "Bob"
      @claim_form_page.defendants.first.last_name.set "Billiards"
      @claim_form_page.defendants.first.dob.set_date "1955-01-01"
      @claim_form_page.defendants.last.representation_orders.first.date.set_date date
      @claim_form_page.defendants.last.representation_orders.first.maat_reference.set "1234567890"
    end
end

When(/^I add another (.*?)defendant, representation order and MAAT reference$/) do |scheme_text|
  date = scheme_text.match?('scheme 10') || scheme_text.match?('post agfs reform') ? Settings.agfs_fee_reform_release_date.strftime : "2016-01-01"
  using_wait_time 6 do
    @claim_form_page.add_another_defendant.click
    wait_for_ajax
    @claim_form_page.defendants.last.first_name.set "Ned"
    @claim_form_page.defendants.last.last_name.set "Kelly"
    @claim_form_page.defendants.last.dob.set_date "1912-12-12"
    @claim_form_page.defendants.last.add_another_representation_order.click
    sleep 1
    # do it again if the first click failed
    @claim_form_page.defendants.last.add_another_representation_order.click if @claim_form_page.defendants.last.representation_orders.first.nil?
    @claim_form_page.defendants.last.representation_orders.first.date.set_date date
    @claim_form_page.defendants.last.representation_orders.first.maat_reference.set "1234567890"
  end
end

When(/^I upload (\d+) documents?$/) do |count|
  @document_count = count.to_i
  @claim_form_page.attach_evidence(count: @document_count)
end

When(/^I upload the document '(.*)'$/) do |document|
  @claim_form_page.attach_evidence(document: document)
end

When(/^I check the boxes for the uploaded documents$/) do
  @claim_form_page.check_evidence_checklist(@document_count || 1)
end

When(/^I check the evidence boxes for\s+'([^']*)'$/) do |labels|
  labels = labels.split(',')
  labels.each do |label|
    @claim_form_page.evidence_checklist.check(label)
  end
end

Then(/^I should see evidence boxes for\s+'([^']*)'$/) do |labels|
  labels = labels.split(',')
  expect(@claim_form_page.evidence_checklist).to be_visible
  expect(@claim_form_page.evidence_checklist.labels).to match_array(labels)
end

# NOTE: can't use have_items because, at least, LAC1 check box may not have a label/be-hidden
Then(/^I should see (\d+)\s*evidence check boxes$/) do |count|
  expect(@claim_form_page.evidence_checklist).to be_visible
  expect(@claim_form_page.evidence_checklist.labels.count).to eql(count.to_i) if count.present?
end

When(/^I add some additional information$/) do
  @claim_form_page.additional_information.set "Bish bosh bash"
end

When(/^I click Submit to LAA$/) do
  allow(Aws::SNS::Client).to receive(:new).and_return Aws::SNS::Client.new(region: 'eu_west_1', stub_responses: true)
  @claim_form_page.submit_to_laa.trigger "click"
end

Then(/^I should be on the check your claim page$/) do
  @claim_summary_page.wait_for_continue # Allow summary page to appear
  expect(@claim_summary_page).to be_displayed
end

When(/^I save as draft$/) do
  # @claim_form_page.save_to_drafts.trigger('click')
  @claim_form_page.save_to_drafts.click
end

When(/^I click "Continue"$/) do
  @claim_summary_page.continue.click
end

When(/^I click "Continue" in the claim form$/) do
  sleep 3
  @claim_form_page.continue_button.click
  wait_for_ajax
end
