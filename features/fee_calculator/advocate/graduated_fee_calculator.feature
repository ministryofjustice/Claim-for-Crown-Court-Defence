@javascript
Feature: Advocate completes graduated (a.k.a basic) fee page using calculator

  @fee_calc_vcr
  Scenario: I create a scheme 9 AGFS graduated trial fee claim using calculated value

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I enter a providers reference of 'AGFS test graduated fee calculation'
    And I select a case type of 'Trial'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter scheme 9 trial long start and end dates
    And I enter scheme 9 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, scheme 9 representation order and MAAT reference
    And I add another defendant, scheme 9 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    Given I insert the VCR cassette 'features/fee_calculator/advocate/graduated_fee_trial_calculator'

    When I select the offence category 'Murder'
    And I click "Continue" in the claim form
    And I should be in the 'Graduated fees' form page
    # Flickers alot (related to page load speed problems??)
    # Then the basic fee net amount should be populated with '0.00'

    # advocate category impacts "basic" fee
    When I select an advocate category of 'Junior alone'
    And the basic fee net amount should be populated with '1632.00'
    And I select an advocate category of 'KC'
    Then the basic fee net amount should be populated with '2856.00'

    When I select the govuk field 'Daily attendance fee (3 to 40)' basic fee with quantity of 38
    And I select the govuk field 'Daily attendance fee (41 to 50)' basic fee with quantity of 10
    And I select the govuk field 'Daily attendance fee (51+)' basic fee with quantity of 2
    And I select the govuk field 'Standard appearance fee' basic fee with quantity of 1
    And I select the govuk field 'Plea and trial preparation hearing' basic fee with quantity of 1
    And I select the govuk field 'Conferences and views' basic fee with quantity of 1
    And I select the govuk field 'Number of defendants uplift' basic fee with quantity of 1
    And I select the govuk field 'Number of cases uplift' basic fee with quantity of 1 with case numbers

    Then the following fee details should exist:
      | section | fee_description                    | rate   | hint                            | help |
      | basic   | Daily attendance fee (3 to 40)     | 979.00 | Number of days                  | true |
      | basic   | Daily attendance fee (41 to 50)    | 387.00 | Number of days                  | true |
      | basic   | Daily attendance fee (51+)         | 414.00 | Number of days                  | true |
      | basic   | Standard appearance fee            | 173.00 | Number of days                  | true |
      | basic   | Plea and trial preparation hearing | 173.00 | Number of additional cases      | true |
      | basic   | Conferences and views              | 74.00  | Number of hours                 | true |
      | basic   | Number of defendants uplift        | 571.20 | Number of additional defendants | true |
      | basic   | Number of cases uplift             | 571.20 | Number of additional cases      | true |

    When I enter '10' prosecution witnesses
    Then the prosecution witnesses net amount should be populated with '0.00'
    When I enter '11' prosecution witnesses
    Then the prosecution witnesses net amount should be populated with '6.53'

    When I enter '50' pages of prosecution evidence
    Then the pages of prosecution evidence net amount should be populated with '0.00'
    When I enter '51' pages of prosecution evidence
    Then the pages of prosecution evidence net amount should be populated with '1.63'

    When I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page

    # offence impact on "basic" fee
    When I goto claim form step 'offence details'
    And I select the offence category 'Activities relating to opium'
    And I click "Continue" in the claim form
    Then the basic fee net amount should be populated with '2529.00'
    Then the following fee details should exist:
      | section | fee_description                    | rate   | hint                            | help |
      | basic   | Daily attendance fee (3 to 40)     | 857.00 | Number of days                  | true |
      | basic   | Daily attendance fee (41 to 50)    | 387.00 | Number of days                  | true |
      | basic   | Daily attendance fee (51+)         | 414.00 | Number of days                  | true |
      | basic   | Standard appearance fee            | 173.00 | Number of days                  | true |
      | basic   | Plea and trial preparation hearing | 173.00 | Number of additional cases      | true |
      | basic   | Conferences and views              | 74.00  | Number of hours                 | true |
      | basic   | Number of defendants uplift        | 505.80 | Number of additional defendants | true |
      | basic   | Number of cases uplift             | 505.80 | Number of additional cases      | true |
    And the prosecution witnesses net amount should be populated with '6.53'
    And the pages of prosecution evidence net amount should be populated with '1.63'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
    And the following fees should have their price_calculated set to true: 'BABAF,BADAF,BADAH,BADAJ,BASAF,BAPCM,BACAV,BANDR,BANOC,BANPW,BAPPE'

  @fee_calc_vcr
  Scenario: I create a scheme 9 AGFS graduated fee Retrial claim using calculated values

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I enter a providers reference of 'AGFS test graduated fee calculation'
    And I select a case type of 'Retrial'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter scheme 9 retrial long start and end dates
    And I choose to apply retrial reduction
    And I enter scheme 9 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, scheme 9 representation order and MAAT reference
    And I add another defendant, scheme 9 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    Given I insert the VCR cassette 'features/fee_calculator/advocate/graduated_fee_retrial_calculator'

    When I select the offence category 'Murder'
    And I click "Continue" in the claim form
    And I should be in the 'Graduated fees' form page
    Then the basic fee net amount should be populated with '0.00'

    # advocate category impacts "basic" fee (retrial interval within a month, 30% reduction)
    When I select an advocate category of 'Junior alone'
    Then the basic fee net amount should be populated with '1142.40'
    When I select an advocate category of 'KC'
    Then the basic fee net amount should be populated with '1999.20'

    When I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page

    # offence impact on "basic" fee
    When I goto claim form step 'offence details'
    And I select the offence category 'Activities relating to opium'
    And I click "Continue" in the claim form
    Then the basic fee net amount should be populated with '1770.30'

    When I select the govuk field 'Daily attendance fee (3 to 40)' basic fee with quantity of 38
    And I select the govuk field 'Daily attendance fee (41 to 50)' basic fee with quantity of 10
    And I select the govuk field 'Daily attendance fee (51+)' basic fee with quantity of 2
    And I select the govuk field 'Standard appearance fee' basic fee with quantity of 1
    And I select the govuk field 'Plea and trial preparation hearing' basic fee with quantity of 1
    And I select the govuk field 'Conferences and views' basic fee with quantity of 1
    And I select the govuk field 'Number of defendants uplift' basic fee with quantity of 1
    And I select the govuk field 'Number of cases uplift' basic fee with quantity of 1 with case numbers

    # retrial interval impact on "basic" fee (retrial interval <= a month, 30% reduction)
    Then the following fee details should exist:
      | section | fee_description                    | rate   | hint                            | help |
      | basic   | Daily attendance fee (3 to 40)     | 599.90 | Number of days                  | true |
      | basic   | Daily attendance fee (41 to 50)    | 387.00 | Number of days                  | true |
      | basic   | Daily attendance fee (51+)         | 414.00 | Number of days                  | true |
      | basic   | Standard appearance fee            | 173.00 | Number of days                  | true |
      | basic   | Plea and trial preparation hearing | 173.00 | Number of additional cases      | true |
      | basic   | Conferences and views              | 74.00  | Number of hours                 | true |
      | basic   | Number of defendants uplift        | 354.06 | Number of additional defendants | true |
      | basic   | Number of cases uplift             | 354.06 | Number of additional cases      | true |

    When I enter '10' prosecution witnesses
    Then the prosecution witnesses net amount should be populated with '0.00'
    When I enter '11' prosecution witnesses
    Then the prosecution witnesses net amount should be populated with '4.57'

    When I enter '50' pages of prosecution evidence
    Then the pages of prosecution evidence net amount should be populated with '0.00'
    When I enter '51' pages of prosecution evidence
    Then the pages of prosecution evidence net amount should be populated with '1.14'

    # retrial interval impact on "basic" fee (retrial interval greater than a month, 20% reduction)
    When I click "Continue" in the claim form
    And I goto claim form step 'case details'
    And I enter retrial long start and end dates with 32 day interval
    And I click "Continue" in the claim form
    And I goto claim form step 'basic fees'
    Then the basic fee net amount should be populated with '2023.20'
    And the following fee details should exist:
      | section | fee_description                    | rate   | hint                            | help |
      | basic   | Daily attendance fee (3 to 40)     | 685.60 | Number of days                  | true |
      | basic   | Daily attendance fee (41 to 50)    | 387.00 | Number of days                  | true |
      | basic   | Daily attendance fee (51+)         | 414.00 | Number of days                  | true |
      | basic   | Standard appearance fee            | 173.00 | Number of days                  | true |
      | basic   | Plea and trial preparation hearing | 173.00 | Number of additional cases      | true |
      | basic   | Conferences and views              | 74.00  | Number of hours                 | true |
      | basic   | Number of defendants uplift        | 404.64 | Number of additional defendants | true |
      | basic   | Number of cases uplift             | 404.64 | Number of additional cases      | true |

    When I enter '10' prosecution witnesses
    Then the prosecution witnesses net amount should be populated with '0.00'
    When I enter '11' prosecution witnesses
    Then the prosecution witnesses net amount should be populated with '5.22'

    When I enter '50' pages of prosecution evidence
    Then the pages of prosecution evidence net amount should be populated with '0.00'
    When I enter '51' pages of prosecution evidence
    Then the pages of prosecution evidence net amount should be populated with '1.30'

    # retrial reduction impact on "basic" fee
    When I goto claim form step 'case details'
    And I choose not to apply retrial reduction
    And I click "Continue" in the claim form
    And I goto claim form step 'basic fees'
    Then the basic fee net amount should be populated with '2529.00'
    And the following fee details should exist:
      | section | fee_description                    | rate   | hint                            | help |
      | basic   | Daily attendance fee (3 to 40)     | 857.00 | Number of days                  | true |
      | basic   | Daily attendance fee (41 to 50)    | 387.00 | Number of days                  | true |
      | basic   | Daily attendance fee (51+)         | 414.00 | Number of days                  | true |
      | basic   | Standard appearance fee            | 173.00 | Number of days                  | true |
      | basic   | Plea and trial preparation hearing | 173.00 | Number of additional cases      | true |
      | basic   | Conferences and views              | 74.00  | Number of hours                 | true |
      | basic   | Number of defendants uplift        | 505.80 | Number of additional defendants | true |
      | basic   | Number of cases uplift             | 505.80 | Number of additional cases      | true |
    And the prosecution witnesses net amount should be populated with '6.53'
    And the pages of prosecution evidence net amount should be populated with '1.63'

    And I eject the VCR cassette

    When I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page
    And the following fees should have their price_calculated set to true: 'BABAF,BADAF,BADAH,BADAJ,BASAF,BAPCM,BACAV,BANDR,BANOC,BANPW,BAPPE'

  @fee_calc_vcr
  Scenario: I create a scheme 9 AGFS graduated discontinuance fee claim using calculated value

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I enter a providers reference of 'AGFS test graduated fee calculation'
    And I select a case type of 'Discontinuance'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter scheme 9 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, scheme 9 representation order and MAAT reference
    And I add another defendant, scheme 9 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    Given I insert the VCR cassette 'features/fee_calculator/advocate/graduated_fee_trial_calculator'

    When I select the offence category 'Murder'
    And I click "Continue" in the claim form
    And I should be in the 'Graduated fees' form page

    Then I should not see 'Pages of prosecution evidence (PPE)'
    And I should not see 'Prosecution witnesses'
    And I should see 'Was prosecution evidence served on this case?'

    When I select an advocate category of 'Junior alone'

    And the basic fee net amount should be populated with '489.50'

    When I choose govuk radio 'Yes' for 'Was prosecution evidence served on this case?'
    And the basic fee net amount should be populated with '979.00'

    When I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page
    And the following fees should have their price_calculated set to true: 'BABAF'

    When I click "Continue" in the claim form
    When I click "Continue" in the claim form
    When I click "Continue" in the claim form
    Then I should see "Was prosecution evidence served on this case? Yes"

    And I eject the VCR cassette
