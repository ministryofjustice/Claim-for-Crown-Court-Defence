Feature: claims are only accessible to the correct authorised users
  As an anonymous user
  I cannot do anything at all with any claim

  As an advocate admin
  I am able to mange claims from my providers and should not be able to manage claims
  from other providers.

  As an advocate
  I am able to read claims from my providers and should not be able to do ANYTHING to
  claims from other providers or other advocates within my providers.

  As a case worker
  I am able to mange any claim

  Scenario: The general public cannot access any claims
    Given an "advocate" user account exists
    When a claim exists that belongs to the advocate
    Then an anonymous user cannot access the claim

  Scenario: The advocate who uploaded the claim can access it
    Given an "advocate" user account exists
    And that advocate signs in
    When a claim exists that belongs to the advocate
    Then the advocate can access the claim

  Scenario: An advocate admin from the same provider as the advocate who uploaded the claim can manage it
    Given an "advocate" user account exists
    And 1 "advocate admin" user account exists who works for the same provider
    When a claim exists that belongs to the advocate
    And that advocate admin signs in
    Then the advocate admin can manage the claim

  Scenario: An advocate admin from a different provider from the advocate who uploaded the claim cannot manage it
    Given an "advocate" user account exists
    And 1 "advocate admin" user account exists who works for different providers
    When a claim exists that belongs to the advocate
    And that advocate admin signs in
    Then the advocate admin cannot manage the claim

  Scenario: An advocate admin from a different provider from the advocate who uploaded the claim cannot manage it
    Given an "advocate" user account exists
    And 1 "advocate admin" user account exists who works for different providers
    When a claim exists that belongs to the advocate
    And that advocate admin signs in
    Then the advocate admin cannot manage the claim

  Scenario: Advocates from the same provider cannot access each others claims
    Given 2 "advocate" user accounts exist who work for the same provider
    When a claim exists that belongs to the 1st advocate
    And the 2nd advocate signs in
    Then that advocate cannot access the claim

  Scenario: Advocates from different providers cannot access each others claims
    Given 2 "advocate" user accounts exist who work for different providers
    When a claim exists that belongs to the 1st advocate
    And the 2nd advocate signs in
    Then that advocate cannot access the claim

  Scenario: Case worker can access all claims
    Given 2 "advocate" user accounts exist who work for different providers
    And a "case worker" user account exists
    When a claim exists that belongs to the 1st advocate
    When a claim exists that belongs to the 2nd advocate
    And that case worker signs in
    Then the case worker can access all claims
