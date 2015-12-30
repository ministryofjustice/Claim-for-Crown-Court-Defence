Feature: Documents are only accessible to the correct authorised users
  As a user
  I want to know that only those authorised to view certain documents are able to do so
  so that security concerns are minimised and bill documentation does not become confused.

  Scenario: The general public cannot access any documents
    Given an "advocate" user account exists
    When a document exists that belongs to the advocate
    Then an anonymous user cannot access the document

  Scenario: The advocate who uploaded the document can access it
    Given an "advocate" user account exists
    And that advocate signs in
    When a document exists that belongs to the advocate
    Then the advocate can access the document

  Scenario: Advocates from the same provider cannot access each others documents
    Given 2 "advocate" user accounts exist who work for the same provider
    When a document exists that belongs to the 1st advocate
    And the 2nd advocate signs in
    Then that advocate cannot access the document

  Scenario: Advocates from different providers cannot access each others documents
    Given 2 "advocate" user accounts exist who work for different providers
    When a document exists that belongs to the 1st advocate
    And the 2nd advocate signs in
    Then that advocate cannot access the document

  Scenario: Case worker can access all documents
    Given 2 "advocate" user accounts exist who work for different providers
    And a "case worker" user account exists
    When a document exists that belongs to the 1st advocate
    When a document exists that belongs to the 2nd advocate
    And that case worker signs in
    Then the case worker can access all documents
