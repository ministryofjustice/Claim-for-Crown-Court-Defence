@javascript
Feature: Litigator partially fills out a draft interim claim, then later edits and submits it

  @fee_calc_vcr
  Scenario: I create an interim claim, save it to draft and later complete it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator interim fee'
    Then I should be on the litigator new interim claim page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS test interim fee'
    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter a case number of 'A20161234'

    And I should see a page title "Enter case details for litigator interim fees claim"
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I should see a page title "Enter defendant details for litigator interim fees claim"
    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit the claim's defendants

    And I enter defendant, LGFS representation order and MAAT reference
    And I add another defendant, LGFS representation order and MAAT reference

    And I should see a page title "Enter defendant details for litigator interim fees claim"
    Then I click "Continue" in the claim form

    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    Given I insert the VCR cassette 'features/claims/litigator/interim_fee_calculations'

    And I should see a page title "Enter offence details for litigator interim fees claim"
    When I click "Continue" in the claim form

    And I should be in the 'Interim fee' form page
    And I should see interim fee types applicable to a 'Trial'

    Then I select an interim fee type of 'Effective PCMH'
    And the interim fee amount should be populated with '201.81'
    And I enter 50 in the PPE total field
    And the interim fee amount should be populated with '201.81'
    And I enter 51 in the PPE total field
    And the interim fee amount should be populated with '205.78'

    And I enter the effective PCMH date '2018-04-01'

    And I add a disbursement 'Computer experts' with net amount '125.40' and vat amount '25.08'
    And I add another disbursement 'Meteorologist' with net amount '58.22' and vat amount '0'

    And I eject the VCR cassette

    And I should see a page title "Enter fees for litigator interim fees claim"
    Then I click "Continue" in the claim form and move to the 'Supporting evidence' form page

    And I upload the document 'indictment.pdf'
    And I check the evidence boxes for 'A copy of the indictment'
    And I add some additional information

    And I should see a page title "Upload supporting evidence for litigator interim fees claim"
    And I click Submit to LAA
    Then I should be on the check your claim page
    And I should see 'Blackfriars'
    And I should see 'A20161234'
    And I should see 'Trial'

    And I should see 'Handling stolen goods'
    And I should see 'G: Other offences of dishonesty between £30,001 and £100,000'

    And I should see 'Interim fees'
    And I should see 'PPE total at the time'
    And I should see '51'
    And I should see 'Effective PCMH'
    And I should see '01/04/2018'
    And I should see '£205.78'

    And I should see 'Disbursements'
    And I should see 'Computer experts'
    And I should see '£125.40'
    And I should see '£25.08'
    And I should see 'Meteorologist'
    And I should see '£58.22'
    And I should see '£0.00'

    And I should see 'indictment.pdf'
    And I should see 'A copy of the indictment'
    And I should see 'Bish bosh bash'

    And I should see a page title "View claim summary for litigator interim fees claim"
    When I click "Continue"
    Then I should be on the certification page

    And I should see a page title "Certify and submit the litigator interim fees claim"
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£414.48'
