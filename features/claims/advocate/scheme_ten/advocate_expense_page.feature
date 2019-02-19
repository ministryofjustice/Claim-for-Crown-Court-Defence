@javascript @establishments
Feature: Advocate creates, saves, edits claims and expenses

  Scenario: Travel expenses page
    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I enter a case number of 'A20181234'
    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter scheme 10 trial start and end dates

    And I should see a page title "Enter case details for advocate final fees claim"
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20181234' should be listed with a status of 'Draft'

    When I click the claim 'A20181234'
    And I edit the claim's expenses

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for scheme 9

    Then I should see 'Expense 1'
    Then I should not see 'Location'

    And I select an expense type "Hotel accommodation"
    And I select a travel reason "Court hearing"
    Then I should see 'Location'

    And I select an expense type "Bike travel"
    And I select a travel reason "Other"
    And I add an expense distance of "873"

    And I add an other reason of "Other reason text"

    And I select a mileage rate of '20p per mile'

    Then I should see 'Distance'
    Then I should see 'Cost per mile'
    Then I should see '20p per mile'
    Then I should see 'Other reason'

    And I should see a page title "Enter travel expenses for advocate final fees claim"
    And I save as draft

    When I click the claim 'A20181234'
    Then I should see 'Bike travel'
    Then I should see 'Other reason text'
    Then I should see '20p'
    Then I should see '873'
    Then I should see '£174.60'
