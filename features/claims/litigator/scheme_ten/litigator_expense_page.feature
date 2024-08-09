@javascript @establishments
Feature: Litigator expense specific page features

  Scenario: I create a final fee claim, save it to draft and later do expenses

    Given the current date is '2022-10-30'
    And I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I choose the supplier number '1A222Z'
    And I should see the London rates radios
    And I select 'Yes' to London rates
    And I select a case type of 'Trial'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2022-10-01'
    And I enter lgfs scheme 10 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    When I click the claim 'A20161234'
    And I edit the claim's expenses
    Then I should see a page title "Enter travel expenses for litigator final fees claim"

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for LGFS Scheme 10

    Then I should see 'Expense'
    Then I should not see 'Location'

    And I select an expense type "Hotel accommodation"
    And I select a travel reason "Court hearing (Crown court)"
    Then I should see a destination label of "Crown court"

    And I select a travel reason "Court hearing (Magistrates' court)"
    Then I should see a destination label of "Magistrates' court"

    And I select an expense type "Bike travel"
    And I select a travel reason "Other"
    And I add an expense location of 'My other location'
    And I add an expense distance of "873"
    And I add an other reason of "Other reason text"

    Given I should not see 'Expense 1'
    When I click the link 'Duplicate last expense'
    Then I should see 'Expense 1'
    And I should see 'Expense 2'

    When I click the first 'Remove' link
    Then I should not see 'Expense 1'
    And I should not see 'Expense 2'
    But I should see 'Expense'

    When I save as draft
    Then I click the claim 'A20161234'
    Then I should see 'Bike travel'
    And I should see 'Destination: My other location'
    And I should see 'Cost per mile: 20p per mile'
    And I should see 'Distance: 873 miles'
    And I should see 'Other reason text'
    And I should see '£174.60'
