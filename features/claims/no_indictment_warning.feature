@javascript @no-seed @vat-seeds
Feature: Evidence page "no indictment" warning

  Background:
    Given popups are enabled

  Scenario: A litigator final claim for a graduated fee accepts warning when indictment not checked
    Given I am a signed in litigator with final claim 'A20214321'
    And I am on the 'Your claims' page

    When I click the claim 'A20214321'
    And I edit the claim's supporting evidence
    Then I should be in the 'Supporting evidence' form page
    And I should see a page title "Upload supporting evidence for litigator final fees claim"

    When I click "Continue" in the claim form and accept "no indictment" popup
    Then I should be on the check your claim page

  Scenario: A litigator final claim for a graduated fee cancels warning and ticks indictment checkbox
    Given I am a signed in litigator with final claim 'A20214321'
    And I am on the 'Your claims' page

    When I click the claim 'A20214321'
    And I edit the claim's supporting evidence
    Then I should be in the 'Supporting evidence' form page
    And I should see a page title "Upload supporting evidence for litigator final fees claim"

    When I click "Continue" in the claim form and dismiss "no indictment" popup
    Then I should be in the 'Supporting evidence' form page

    When I check the evidence boxes for 'Copy of the indictment'
    And I click "Continue" in the claim form
    Then I should be on the check your claim page

  Scenario: An advocate final claim for a graduated fee accepts warning when indictment not checked
    Given I am a signed in advocate with final claim 'A20214321'
    And I am on the 'Your claims' page

    When I click the claim 'A20214321'
    And I edit the claim's supporting evidence
    Then I should be in the 'Supporting evidence' form page
    And I should see a page title "Upload supporting evidence for advocate final fees claim"

    When I click "Continue" in the claim form and accept "no indictment" popup
    Then I should be on the check your claim page

  Scenario: An advocate final claim for a fixed fee does NOT receive a warning when indictment not checked
    Given I am a signed in advocate with fixed fee claim 'A20214321'
    And I am on the 'Your claims' page

    When I click the claim 'A20214321'
    And I edit the claim's supporting evidence
    Then I should be in the 'Supporting evidence' form page
    And I should see a page title "Upload supporting evidence for advocate final fees claim"

    When I click "Continue" in the claim form
    Then I should be on the check your claim page
