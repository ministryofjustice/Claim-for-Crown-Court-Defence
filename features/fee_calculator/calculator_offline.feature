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
    And I select a case type of 'Appeal against sentence'
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
    And I am on the miscellaneous fees page
