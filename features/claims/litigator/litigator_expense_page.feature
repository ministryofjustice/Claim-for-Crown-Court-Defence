@javascript @establishments
Feature: Litigator expense specific page features

  Scenario: I create a final fee claim, save it to draft and later do expenses

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I choose the supplier number '1A222Z'
    And I select a case type of 'Trial'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2018-04-01'

    Then I click "Continue" in the claim form

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    When I click the claim 'A20161234'
    And I edit the claim's expenses

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date

    Then I should see 'Expense 1'
    Then I should not see 'Destination'

    And I select an expense type "Hotel accommodation"
    And I select a travel reason "Court hearing (Crown court)"
    Then I should see a destination label of "Crown court"

    And I select a travel reason "Court hearing (Magistrates' court)"
    Then I should see a destination label of "Magistrates court"

    And I select an expense type "Bike travel"
    And I select a travel reason "Other"
    And I add an expense distance of "873"
    And I add an other reason of "Other reason text"

    Then I should see 'Destination'
    Then I should see 'Distance'
    Then I should see 'Cost per mile'
    Then I should see '20p per mile'
    Then I should see 'Other reason'

    Then I click "Continue" in the claim form
