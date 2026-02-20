@javascript
Feature: Litigator partially fills out a draft interim claim, then later edits and submits it

  Scenario: I create an interim claim, save it to draft and later complete it

    Given the current date is '2026-03-03'
    And I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator interim fee'
    Then I should be on the litigator new interim claim page

    When I choose the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter a case number of 'A20161234'
    And I enter lgfs scheme 11 main hearing date
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I enter defendant, LGFS Fee Scheme 11 representation order and MAAT reference
    And I add another defendant, LGFS Fee Scheme 11 representation order and MAAT reference

    Then I click "Continue" in the claim form

    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    Given I insert the VCR cassette 'features/claims/litigator/interim_warrant_fee_calculations'

    Then I click "Continue" in the claim form

    And I should be in the 'Interim fee' form page
    And I select an interim fee type of 'Warrant'
    And the interim fee amount should be populated with ''
    And I enter '2026-03-03' as the warrant issued date
    And I enter '2026-03-03' as the warrant executed date
    And I enter '680.39' in the interim fee total field

    And I eject the VCR cassette

    Then I click "Continue" in the claim form

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for LGFS Scheme 11

    Then I click "Continue" in the claim form

    And I upload 1 document
    And I check the boxes for the uploaded documents
    And I check the evidence boxes for 'Copy of the indictment'
    And I add some additional information

    And I click Submit to LAA
    Then I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page

    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£721.86'
