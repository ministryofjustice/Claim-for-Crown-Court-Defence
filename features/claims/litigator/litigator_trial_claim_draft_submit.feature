@javascript
Feature: Litigator partially fills out a draft final fee claim, then later edits and submits it

  Scenario: I create a final fee claim, save it to draft and later complete it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    And I should see 3 supplier number radios

    When I choose the supplier number '1A222Z'
    And I select a case type of 'Trial'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2018-04-01'

    Then I click "Continue" in the claim form

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    And 6+ supplier numbers exist for my provider
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit the claim's case details

    Then I should see a supplier number select list

    Then I click "Continue" in the claim form

    And I enter defendant, post agfs reform representation order and MAAT reference
    And I add another defendant, post agfs reform representation order and MAAT reference

    Then I click "Continue" in the claim form

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

    Then I click "Continue" in the claim form

    And I fill '125' as the ppe total
    And I fill '5' as the actual trial length
    And I fill '100.25' as the graduated fee total
    And I fill '2018-04-02' as the graduated fee date

    Then I click "Continue" in the claim form

    And I add a litigator miscellaneous fee 'Costs judge application'
    And I add a litigator miscellaneous fee 'Defendant uplift'

    Then I click "Continue" in the claim form

    And I add a disbursement 'Computer experts' with net amount '125.40' and vat amount '25.08'
    And I add another disbursement 'Meteorologist' with net amount '58.22' and vat amount '0'

    Then I click "Continue" in the claim form

    And I add an expense 'Parking'

    Then I click "Continue" in the claim form

    And I upload 1 document
    And I check the boxes for the uploaded documents
    And I check the evidence boxes for 'A copy of the indictment'
    And I add some additional information

    And I click Submit to LAA
    Then I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page

    And I click Certify and submit claim
    Then I should be on the page showing basic claim information

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£615.07'
