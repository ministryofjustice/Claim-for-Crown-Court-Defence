@javascript
Feature: Litigator partially fills out a draft interim claim, then later edits and submits it

  Scenario: I create an interim claim, save it to draft and later complete it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page

    And I click 'Start a claim'
    And I select the fee scheme 'Litigator interim fee'
    Then I should be on the litigator new interim claim page

    When I select the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter a case number of 'A20161234'

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit this claim

    Then I click "Continue" in the claim form

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    Then I click "Continue" in the claim form

    And I select an interim fee type of 'Effective PCMH'
    And I enter 10 in the PPE total field
    And I enter 250 in the interim fee total field
    And I enter the effective PCMH date

    And I add a disbursement 'Computer experts' with net amount '125.40' and vat amount '30.5'
    And I add another disbursement 'Meteorologist' with net amount '58.22' and vat amount '0'

    And I upload 1 document
    And I check the boxes for the uploaded documents
    And I add some additional information
    And I click Submit to LAA
    Then I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page

    And I click Certify and submit claim
    Then I should be on the page showing basic claim information

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£464.12'
