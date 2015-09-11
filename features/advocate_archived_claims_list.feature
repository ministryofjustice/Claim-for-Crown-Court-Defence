Feature: Advocate archived claims list
  Background:
    As an advocate I want to see all my archivedclaims.

 Scenario: View archived claims list as an advocate admin
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has 3 "submitted" claims for advocate "John Smith"
      And my chamber has 2 "archived_pending_delete" claims for advocate "Bob Smith"
     When I visit the advocate archive
     Then I should see 2 "archived_pending_delete" claims listed
      And I should not see non-archived claims listed

  Scenario: View archived claims list as an advocate
    Given I am a signed in advocate
      And There are fee schemes in place
      And I have 3 "submitted" claims
      And I have 2 "archived_pending_delete" claims
     When I visit the advocate archive
     Then I should see 2 "archived_pending_delete" claims listed
      And I should not see non-archived claims listed
