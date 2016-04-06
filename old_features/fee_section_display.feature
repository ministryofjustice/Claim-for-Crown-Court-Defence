Feature: Fee section display by case type
  Background:
    As an advocate I want to see appropriate fee sections displayed according to the case type I select

    Given case types are seeded

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Case types for which fixed fees should or should not be visible on a new claim
    Given I am a signed in advocate
      And I am on the new claim page
     When I select2 "<case_type>" from "claim_case_type_id"
     Then I <condition> see the fixed-fees section

  Examples:
    | case_type                   | condition  |
    | Appeal against conviction   | should     |
    | Appeal against sentence     | should     |
    | Breach of Crown Court order | should     |
    | Committal for Sentence      | should     |
    | Contempt                    | should     |
    | Cracked Trial               | should not |
    | Cracked before retrial      | should not |
    | Discontinuance              | should not |
    | Elected cases not proceeded | should     |
    | Guilty plea                 | should not |
    | Retrial                     | should not |
    | Trial                       | should not |

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Case types for which basic fees should or should not be visible on a new claim
    Given I am a signed in advocate
      And I am on the new claim page
     When I select2 "<case_type>" from "claim_case_type_id"
     Then I <condition> see the basic-fees section

  Examples:
    | case_type                   | condition  |
    | Appeal against conviction   | should not |
    | Appeal against sentence     | should not |
    | Cracked Trial               | should     |
    | Retrial                     | should     |
    | Trial                       | should     |

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: All case types should have a miscellaneous fee section visible on a new claim
    Given I am a signed in advocate
      And I am on the new claim page
     When I select2 "<case_type>" from "claim_case_type_id"
     Then I <condition> see the misc-fees section

Examples:
    | case_type                   | condition  |
    | Appeal against conviction   | should     |
    | Trial                       | should     |
