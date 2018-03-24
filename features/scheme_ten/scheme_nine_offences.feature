@javascript
Feature: Litigator starts a new claim after scheme 10 has been implemented

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

    When I choose the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date

    And I click "Continue" in the claim form

    And I enter defendant, representation order and MAAT reference
    And I click "Continue" in the claim form

    When I select the offence category 'Abandonment of children under two'
    Then the offence_class drop_down is set to 'C: Lesser offences involving violence or damage and less serious drug offences'
    And the offence_class drop_down has 1 options

    When I select the offence category 'Murder'
    Then the offence_class drop_down is set to 'A: Homicide and related grave offences'
    And the offence_class drop_down has 1 options

    When I select the offence category 'Abstraction of electricity'
    Then the offence_class drop_down is set to 'F: Other offences of dishonesty up to £30,000'
    And the offence_class drop_down has 3 options

