@javascript
Feature: Advocate completes fixed fees, but calculator offline

  @stub_calculator_request_and_fail
  Scenario: I create a contempt claim, then submit it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Blackfriars'
    And I select a case type of 'Contempt'
    And I enter a case number of 'A20161234'

    Then I click "Continue" in the claim form

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    And I select an advocate category of 'Junior alone'
    And I add a fixed fee 'Appeals to the crown court against sentence'
    Then the last fixed fee case numbers section should not be visible
    Then the last fixed fee rate should be in the calculator error state
    When I set the last fixed fee value to '108.00'
    Then I click "Continue" in the claim form

    And I add a miscellaneous fee 'Adjourned appeals' with dates attended

    Then I click "Continue" in the claim form

    And I add an expense 'Parking'

    Then I click "Continue" in the claim form

    And I upload 3 documents
    And I check the boxes for the uploaded documents
    And I add some additional information

    Then I click Submit to LAA
    And I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the page showing basic claim information

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£212.54'
