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
    And I enter scheme 10 main hearing date

    And I should see a page title "Enter case details for advocate final fees claim"
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20181234' should be listed with a status of 'Draft'

    When I click the claim 'A20181234'
    And I edit the claim's expenses
    Then I should see a page title "Enter travel expenses for advocate final fees claim"

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for scheme 9

    Then I should see 'Expense'
    Then I should not see 'Location'

    And I select an expense type "Hotel accommodation"
    And I select a travel reason "Court hearing"
    Then I should see 'Location'

    And I select an expense type "Bike travel"
    And I select a travel reason "Other"
    And I add an other reason of "Other reason text"
    And I add an expense location of 'My other location'
    And I add an expense distance of "873"
    And I select a mileage rate of '20p per mile'

    Then I should see 'Distance'
    And I should see 'Cost per mile'
    And I should see '20p per mile'
    And I should see 'Other reason'

    Given I should not see 'Expense 1'
    When I click the link 'Duplicate last expense'
    Then I should see 'Expense 1'
    And I should see 'Expense 2'

    When I click the first 'Remove' link
    Then I should not see 'Expense 1'
    And I should not see 'Expense 2'
    But I should see 'Expense'

    When I save as draft
    Then I click the claim 'A20181234'
    Then I should see 'Bike travel'
    And I should see 'Destination: My other location'
    And I should see 'Cost per mile: 20p per mile'
    And I should see 'Distance: 873 miles'
    And I should see 'Other reason text'
    And I should see '£174.60'
