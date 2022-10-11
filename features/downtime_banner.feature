@javascript @no-seed
Feature: A downtime warning banner appears on home pages only until downtime date exceeded

  Background:
    Given the downtime feature flag is enabled
    And the downtime date is set to '2021-05-26'

  Scenario: Downtime warning active until 26 May 2021 for external users
    Given the current date is '2021-05-19'
    When I am a signed in advocate admin
    Then the downtime banner is displayed
    And the downtime banner should say 'This service will be unavailable on Wednesday 26 May 2021 from 5pm until midnight.'
    And the downtime banner should say 'This is to enable routine maintenance work to be carried out. Please save and close any work before this time.'
    And the page should be accessible

    When I visit the fee scheme selector page
    And the downtime banner is not displayed

    When I visit the manage users page
    And the downtime banner is not displayed
    And I go back
    And I am on the 'Your claims' page

    When the current date is '2021-05-26'
    And I am a signed in advocate admin
    And I refresh the page
    Then the downtime banner is displayed

    When the current date is '2021-05-27'
    And I am a signed in advocate admin
    And I refresh the page
    Then the downtime banner is not displayed

  @vat-seeds
  Scenario: Downtime warning active until 26 May 2021 for case workers
    Given the current date is '2021-05-19'
    And case worker "John Smith" exists
    And submitted claims exist with case numbers "T20160001, T20160002, T20160003, T20160004, T20160005"
    And I insert the VCR cassette 'features/case_workers/admin/allocation'

    When I am a signed in case worker admin
    Then the downtime banner is displayed
    And the downtime banner should say 'This service will be unavailable on Wednesday 26 May 2021 from 5pm until midnight.'
    And the downtime banner should say 'This is to enable routine maintenance work to be carried out. Please save and close any work before this time.'
    And the page should be accessible

    When I click the link 'Allocation'
    And the downtime banner is not displayed
    And the page should be accessible

    When I click the link 'Your claims'
    And the downtime banner is displayed
    And the page should be accessible

    When the current date is '2021-05-26'
    And I am a signed in case worker admin
    And I refresh the page
    Then the downtime banner is displayed

    When the current date is '2021-05-27'
    And I am a signed in case worker admin
    And I refresh the page
    Then the downtime banner is not displayed
