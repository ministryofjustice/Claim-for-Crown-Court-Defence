@javascript
Feature: Litigator partially fills out a draft transfer claim, then later edits and submits it

  @fee_calc_vcr
  Scenario: I create a transfer claim, save it to draft and later complete it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator transfer fee'
    Then I should be on the litigator new transfer claim page
    And I should see a page title "Enter fees for litigator transfer fees claim"

    Then I choose the litigator type option 'New'
    And I choose the elected case option 'No'
    And I select the transfer stage 'Before trial transfer'
    And I enter the transfer date 3 years ago
    And I select a case conclusion of 'Cracked'

    And I click "Continue" in the claim form

    When I choose the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date
    And I enter lgfs scheme 9 main hearing date

    And I should see a page title "Enter case details for litigator transfer fees claim"
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I should see a page title "Enter defendant details for litigator transfer fees claim"
    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit the claim's defendants

    And I enter defendant, LGFS representation order and MAAT reference
    And I add another defendant, LGFS representation order and MAAT reference

    And I should see a page title "Enter defendant details for litigator transfer fees claim"
    And I click "Continue" in the claim form

    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    Given I insert the VCR cassette 'features/claims/litigator/transfer_fee_calculations'

    And I should see a page title "Enter offence details for litigator transfer fees claim"
    And I click "Continue" in the claim form

    Then the transfer fee amount should be populated with '269.08'
    And I should not see the days claimed field
    And I should see the ppe field
    And I enter '50' in the PPE total graduated fee field
    Then the transfer fee amount should be populated with '269.08'
    And I enter '51' in the PPE total graduated fee field
    Then the transfer fee amount should be populated with '274.37'

    And I should see a page title "Enter fees for litigator transfer fees claim"
    Then I click "Continue" in the claim form

    And I eject the VCR cassette

    And I should be in the 'Miscellaneous fees' form page
    And the first miscellaneous fee should have fee types 'Costs judge application,Costs judge preparation,Evidence provision fee,Special preparation fee'
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
    And I add an expense date for LGFS

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
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£660.32'

  @fee_calc_vcr
  Scenario: I create a transfer claim for an Elected Case Not Proceeded

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator transfer fee'
    Then I should be on the litigator new transfer claim page
    And I should see a page title "Enter fees for litigator transfer fees claim"

    Then I choose the litigator type option 'New'
    And I choose the elected case option 'Yes'
    And I select the transfer stage 'Before trial transfer'
    And I enter the transfer date 3 years ago

    When I click "Continue" in the claim form
    Then I should see a page title "Enter case details for litigator transfer fees claim"
    And I choose the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date
    And I enter lgfs scheme 9 main hearing date

    When I click "Continue" in the claim form and move to the 'Defendant details' form page
    Then I should see a page title "Enter defendant details for litigator transfer fees claim"

    When I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit the claim's defendants
    Then I should see a page title "Enter defendant details for litigator transfer fees claim"
    And I enter defendant, LGFS representation order and MAAT reference

    When I click "Continue" in the claim form
    Then I should see a page title "Enter offence details for litigator transfer fees claim"
    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    Given I insert the VCR cassette 'features/claims/litigator/transfer_fee_calculations'
    When I click "Continue" in the claim form
    Then I should see a page title "Enter fees for litigator transfer fees claim"
    And the transfer fee amount should be populated with '330.33'
    And I should not see the days claimed field
    And I should not see the ppe field

    Given I eject the VCR cassette
    When I click "Continue" in the claim form
    Then I should see a page title "Enter miscellaneous fees for litigator transfer fees claim"
    When I click "Continue" in the claim form
    Then I should see a page title "Enter disbursements for litigator transfer fees claim"
    When I click "Continue" in the claim form
    Then I should see a page title "Enter travel expenses for litigator transfer fees claim"
    When I click "Continue" in the claim form
    Then I should see a page title "Upload supporting evidence for litigator transfer fees claim"

    When I upload 1 document
    And I check the boxes for the uploaded documents
    And I check the evidence boxes for 'Copy of the indictment'
    And I add some additional information
    And I click Submit to LAA
    Then I should be on the check your claim page
    And I should see a page title "View claim summary for litigator transfer fees claim"
    And I should see 'G: Other offences of dishonesty between £30,001 and £100,000'

    When I click "Continue"
    Then I should see a page title "Certify and submit the litigator transfer fees claim"
    When I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£330.33'
