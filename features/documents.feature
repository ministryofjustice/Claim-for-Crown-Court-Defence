@wip
Feature: Manage documents

  Scenario: Create a document directly
    Given I visit "/documents/new"
     When I upload an example document
     Then The example document should exist on the system
