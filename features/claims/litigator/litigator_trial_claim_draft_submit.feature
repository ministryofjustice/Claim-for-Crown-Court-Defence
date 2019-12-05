@javascript
Feature: Litigator partially fills out a draft final fee claim, then later edits and submits it

  @fee_calc_vcr
  Scenario: I create a final fee claim, save it to draft and later complete it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    Then the page should be accessible within "#content"
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then the page should be accessible within "#content"
    Then I should be on the litigator new claim page
    And I should see a page title "Enter case details for litigator final fees claim"
    And I should see 3 supplier number radios

    When I select a case type of 'Trial'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2016-04-01'
    Then the page should be accessible within "#content"
    Then I click "Continue" I should be on the 'Case details' page and see a "Choose a supplier number" error

    When I choose the supplier number '1A222Z'
    Then the page should be accessible within "#content"
    And I click "Continue" in the claim form
    Then I should be in the 'Defendant details' form page
    And I should see a page title "Enter defendant details for litigator final fees claim"

    When I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    And 6+ supplier numbers exist for my provider
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit the claim's case details
    And I should see a page title "Enter case details for litigator final fees claim"
    And I should see a supplier number select list
    Then the page should be accessible within "#content"

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page
    And I enter defendant, LGFS representation order and MAAT reference
    And I add another defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page
    And I should see a page title "Enter offence details for litigator final fees claim"

    When I select the offence category 'Abandonment of children under two'
    Then the offence class list is set to 'C: Lesser offences involving violence or damage and less serious drug offences'
    And the offence class list has 1 options

    When I select the offence category 'Murder'
    Then the offence class list is set to 'A: Homicide and related grave offences'
    And the offence class list has 1 options

    When I select the offence category 'Abstraction of electricity'
    Then the offence class list is set to 'F: Other offences of dishonesty up to £30,000'
    And the offence class list has 3 options

    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'
    Then the page should be accessible within "#content"

    Given I insert the VCR cassette 'features/claims/litigator/graduated_fee_calculations'

    Then I click "Continue" in the claim form
    And I should see a page title "Enter graduated fees for litigator final fees claim"

    And I fill '2018-01-01' as the graduated fee date
    When I fill '2' as the actual trial length
    Then the graduated fee amount should be populated with '429.12'
    When I enter '51' in the PPE total graduated fee field
    Then the graduated fee amount should be populated with '437.89'
    Then the page should be accessible within "#content"

    Then I click "Continue" in the claim form

    And I eject the VCR cassette

    And I should be in the 'Miscellaneous fees' form page
    And I should see a page title "Enter miscellaneous fees for litigator final fees claim"
    And the first miscellaneous fee should have fee types 'Costs judge application,Costs judge preparation,Evidence provision fee,Special preparation fee'
    And I add a litigator miscellaneous fee 'Costs judge application'
    Then the page should be accessible within "#content"

    When I click "Continue" in the claim form
    Then I should be in the 'Disbursements' form page
    And I should see a page title "Enter disbursements for litigator final fees claim"

    Then I add a disbursement 'Computer experts' with net amount '125.40' and vat amount '25.08'
    And I add another disbursement 'Meteorologist' with net amount '58.22' and vat amount '0'

    When I click "Continue" in the claim form
    Then I should be in the 'Travel expenses' form page
    And I should see a page title "Enter travel expenses for litigator final fees claim"
    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for scheme 10
    Then the page should be accessible within "#content"

    When I click "Continue" in the claim form
    Then I should be in the 'Supporting evidence' form page
    And I should see a page title "Upload supporting evidence for litigator final fees claim"

    And I upload the document 'indictment.pdf'
    And I check the evidence boxes for 'A copy of the indictment'
    And I add some additional information
    Then the page should be accessible within "#content"

    When I click Submit to LAA
    Then I should be on the check your claim page
    And I should see a page title "View claim summary for litigator final fees claim"
    And I should see the field 'Crown court' with value 'Blackfriars' in 'Case details'
    And I should see the field 'Case type' with value 'Trial' in 'Case details'
    And I should see the field 'Date case concluded' with value '01/04/2016' in 'Case details'
    And I should see the field 'Type of fee' with value 'Trial' in 'Graduated fee'
    And I should see the field 'First day of hearing' with value '01/01/2018' in 'Graduated fee'
    And I should see the field 'Actual trial length' with value '2' in 'Graduated fee'
    And I should see the field 'Total pages of evidence' with value '51' in 'Graduated fee'
    And I should see the field 'Net amount' with value '£437.89' in 'Graduated fee'
    And I should not see 'First day of trial'
    And I should not see 'Estimated trial length'
    And I should not see 'Trial concluded on'
    Then the page should be accessible within "#content"

    When I click "Continue"
    Then I should be on the certification page
    And I should see a page title "Certify and submit the litigator final fees claim"
    Then the page should be accessible within "#content"

    When I click Certify and submit claim
    Then I should be on the claim confirmation page
    Then the page should be accessible within "#content"

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£823.84'
    Then the page should be accessible within "#content"
