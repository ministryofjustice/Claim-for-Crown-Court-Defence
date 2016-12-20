@javascript
Feature: Litigator partially fills out a draft transfer claim, then later edits and submits it

  Scenario: I create a transfer claim, save it to draft and later complete it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page

    And I click 'Start a claim'
    And I select the fee scheme 'Litigator transfer fee'
    Then I should be on the litigator new transfer claim page

    And I choose the litigator type option 'New'
    And I choose the elected case option 'No'
    And I select the transfer stage 'Before trial transfer'
    And I enter the transfer date '2015-05-21'
    And I select a case conclusion of 'Cracked'

    And I click "Continue" in the claim form


    When I select the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit this claim
    And I click "Continue" in the claim form

    And I enter the case concluded date
    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference
    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    And I click "Continue" in the claim form

    And I fill in '121.21' as the transfer fee total
    And I add a miscellaneous fee 'Costs judge application'
    And I add a Case uplift fee with case numbers 'A20161234, A20165588'

    And I add a disbursement 'Computer experts' with net amount '125.40' and vat amount '32.50'
    And I add another disbursement 'Meteorologist' with net amount '58.22' and vat amount '0'

    And I add an expense 'Parking'

    And I upload 1 document
    And I check the boxes for the uploaded documents
    And I add some additional information

    Then I click Submit to LAA
    And I should be on the check your claim page
    And I should see 'G: Other offences of dishonesty between £30,001 and £100,000'

    When I click "Continue"
    Then I should be on the certification page

    And I click Certify and submit claim
    Then I should be on the page showing basic claim information

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£643.45'
