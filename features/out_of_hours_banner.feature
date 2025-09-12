@javascript @no-seed
Feature: An out of hours banner will appear until the user dismisses it

  Scenario: I log in as an advocate, see the banner, dismiss it and do not see it again

    Given I am a signed in advocate
    Then the out of hours banner is visible
    And I should see 'This service can only be used from 7am to 7pm, Monday to Friday.'
    Then the page should be accessible

  Scenario: I log in as a litigator, see the banner, dismiss it and do not see it again

    Given I am a signed in litigator
    Then the out of hours banner is visible
    And I should see 'This service can only be used from 7am to 7pm, Monday to Friday.'
    Then the page should be accessible

  Scenario: I log in as a caseworker, see the banner, dismiss it and do not see it again

    Given I insert the VCR cassette 'features/out_of_hours_bannner'
    And I am a signed in case worker
    Then the out of hours banner is visible
    And I should see 'This service can only be used from 7am to 10pm.'
    Then the page should be accessible
