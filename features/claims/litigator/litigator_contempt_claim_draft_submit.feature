@javascript
Feature: Litigator partially fills out a draft final fee claim, then later edits and submits it

  Scenario: I create a final fee claim, save it to draft and later complete it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    Then I should see 3 radio labels
    When I choose the supplier number '1A222Z'
    # And more suppliers are added
    # And I refresh the page

    # When I select the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I select a case type of 'Contempt'
    And I enter a case number of 'A20161234'

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit this claim

    And I enter the case concluded date

    Then I click "Continue" in the claim form

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    And I fill '100.25' as the fixed fee total
    And I enter the fixed fee date
    And I add a miscellaneous fee 'Costs judge application'
    And I add a Case uplift fee with case numbers 'A20161234, A20165588'
    And I add a disbursement 'Computer experts' with net amount '125.40' and vat amount '30.5'
    And I add another disbursement 'Meteorologist' with net amount '58.22' and vat amount '0'
    And I add an expense 'Parking'

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
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£620.49'
