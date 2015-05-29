Feature: Advocate claims list
  Background:
    As an advocate I want to see all my claims.

  Scenario: View claims as an advocate
    Given I am a signed in advocate
      And I have claims
     When I visit the advocates dashboard
     Then I should see only claims that I have created

  Scenario: View claims as an advocate admin
    Given I am a signed in advocate admin
      And my chamber has claims
     When I visit the advocates dashboard
     Then I should see my chamber's claims

  Scenario Outline: View claims
    Given I am a signed in advocate admin
      And my chamber has <number> <state> claims
     When I visit the advocates dashboard
     Then I should see my chamber's <number> <state> claims

     Examples:
       | state        | number |
       | "submitted"  | 5      |
       | "rejected"   | 5      |
       | "part_paid"  | 5      |
       | "completed"  | 5      |
       | "draft"      | 5      |

  Scenario: Search claims by advocate name
    Given I am a signed in advocate admin
      And my chamber has 4 claims for advocate "John Smith"
     When I visit the advocates dashboard
      And I search by the advocate name "John Smith"
     Then I should only see the 4 claims for the advocate "John Smith"

  Scenario: No search by advocate name for non-admin
    Given I am a signed in advocate
     When I visit the advocates dashboard
     Then I should not see the advocate search field

  Scenario Outline: Claims section titles
    Given I am a signed in advocate
     When I visit the advocates dashboard
     Then I should see section titles of <title>

     Examples:
      | title              |
      | "Draft"            |
      | "Rejected"         |
      | "Submitted to LAA" |
      | "Part paid"        |
      | "Completed"        |
