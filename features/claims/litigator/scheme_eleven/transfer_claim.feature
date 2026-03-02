@javascript
Feature: Litigator partially fills out a draft transfer claim, then later edits and submits it

  @fee_calc_vcr
  Scenario: I create a transfer claim, save it to draft and later complete it

    Given the current date is '2026-03-27'
    And I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator transfer fee'
    Then I should be on the litigator new transfer claim page
    And I should see a page title "Enter fees for litigator transfer fees claim"

    Then I choose the litigator type option 'New'
    And I choose the elected case option 'No'
    And I select the transfer stage 'Before trial transfer'
    And I enter the transfer date '2026-03-20'
    And I select a case conclusion of 'Cracked'

    And I click "Continue" in the claim form

    When I choose the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2026-03-20'
    And I enter lgfs scheme 11 main hearing date

    And I should see a page title "Enter case details for litigator transfer fees claim"
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I should see a page title "Enter defendant details for litigator transfer fees claim"
    And I enter defendant, LGFS Scheme 11 representation order and MAAT reference

    And I should see a page title "Enter defendant details for litigator transfer fees claim"
    And I click "Continue" in the claim form

    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    Given I insert the VCR cassette 'features/claims/litigator/transfer_fee_calculations'

    And I should see a page title "Enter offence details for litigator transfer fees claim"
    And I click "Continue" in the claim form
    And I should not see the days claimed field
    And I should see the ppe field
    And I enter '50' in the PPE total graduated fee field
    Then the transfer fee amount should be populated with '410.38'

    And I should see a page title "Enter fees for litigator transfer fees claim"
    Then I click "Continue" in the claim form

    And I eject the VCR cassette

    And I should be in the 'Miscellaneous fees' form page
    And the first miscellaneous fee should have fee types 'Costs judge application,Costs judge preparation,Evidence provision fee,Special preparation fee,Unused materials (over 3 hours),Unused materials (up to 3 hours)'
    And I add a litigator miscellaneous fee 'Costs judge application'

    And I should see a page title "Enter miscellaneous fees for litigator transfer fees claim"
    Then I click "Continue" in the claim form

    And I add a disbursement 'Computer experts' with net amount '125.40' and vat amount '25.08'
    And I add another disbursement 'Meteorologist' with net amount '58.22' and vat amount '0'

    And I should see a page title "Enter disbursements for litigator transfer fees claim"
    Then I click "Continue" in the claim form
    And I should see a page title "Enter travel expenses for litigator transfer fees claim"

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for LGFS Scheme 11

    When I click "Continue" in the claim form
    Then I should be in the 'Supporting evidence' form page
    And I should see a page title "Upload supporting evidence for litigator transfer fees claim"

    And I upload 1 document
    And I check the boxes for the uploaded documents
    And I check the evidence boxes for 'Copy of the indictment'
    And I add some additional information

    And I should see a page title "Upload supporting evidence for litigator transfer fees claim"
    Then I click Submit to LAA
    And I should be on the check your claim page
    And I should see 'G: Other offences of dishonesty between £30,001 and £100,000'

    And I should see a page title "View claim summary for litigator transfer fees claim"
    When I click "Continue"
    Then I should be on the certification page

    And I should see a page title "Certify and submit the litigator transfer fees claim"
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£796.33'
