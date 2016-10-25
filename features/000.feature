# Do not remove. This feature must always run first on CI.
# Due to some obscure mechanism, sometimes cukes will start with a dirty DB state after running specs, with
# some records already created, which causes hellish problems with VCR cassettes. This feature will reset the DB.
# (I hate cucumber)
#
@javascript
Feature: This feature runs first to sanitize the database.

  Scenario: Logged out I see the login page. Silly test will do the magic.
    Given I visit "/"
    Then I should see 'Sign in'
