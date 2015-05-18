@focus
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
    When the advocate uploads a document
    Then the advocate can download the document

  Scenario: Advocates from the same chamber can access each others documents
    Given 2 "advocate" user accounts exist who work for the same chamber
    When the first advocate uploads a document
    Then the second advocate can download that document

  Scenario: Advocates from different chambers cannot access each others documents
    Given 2 "advocate" user accounts exist who work for different chambers
    When the first advocate uploads a document
    Then the second advocate cannot download that document

  Scenario: Case worker can access all documents
    Given 2 "advocate" user accounts exist who work for different chambers
    And a caseworker exists
    When the both advocates upload documents
    Then the caseworker can access both documents
