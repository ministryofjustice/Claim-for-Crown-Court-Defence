Feature: Claim re-allocation
  Background:
    As a case worker admin I would like to re-allocate allocated claims to case workers

    Given I am a signed in case worker admin
      And case worker "John Smith" exists
      And case worker "Bob Jones" exists
      And submitted claims exist with case numbers "T00000001, T00000002, T00000003, T00000004, T00000005"
      And claims "T00000001, T00000002" have been allocated to "John Smith"
      And I visit the re-allocation page

  Scenario: Re-allocate claims to case worker
    Given I select claims "T00000001, T00000002"
      And I select case worker "Bob Jones"
     When I click Re-allocate
     Then claims "T00000001, T00000002" should be allocated to case worker "Bob Jones"
      And 0 claims should be allocated to case worker "John Smith"
      And I should see a notification 2 claims were allocated to "Bob Jones"

  @javascript @webmock_allow_localhost_connect
  Scenario: Deallocate / Return claims to allocation pool
    Given I choose the "Allocation pool" option
     Then I should no longer see the case workers dropdown
     When I select claims "T00000001, T00000002"
      And I click Re-allocate
     Then 0 claims should be allocated to case worker "John Smith"
      And I should see a notification that 2 claims were deallocated
