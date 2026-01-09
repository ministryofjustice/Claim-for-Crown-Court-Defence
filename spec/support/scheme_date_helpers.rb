module SchemeDateHelpers
  def scheme_date_for(text)
    scheme_date_mappings[text&.downcase&.strip] || '2018-03-31'
  end

  def main_hearing_date_for(text)
    main_hearing_date_mappings[text&.downcase&.strip] || '2018-03-31'
  end

  private

  def scheme_date_mappings
    {
      'scheme 16' => Settings.agfs_scheme_16_section_twenty_eight_increase.strftime,
      'scheme 15' => Settings.agfs_scheme_15_additional_prep_fee_and_kc.strftime,
      'scheme 13' => Settings.agfs_scheme_13_clair_release_date.strftime,
      'scheme 12a' => Settings.clar_release_date.strftime,
      'scheme 12' => Settings.clar_release_date.strftime,
      'scheme 11' => Settings.agfs_scheme_11_release_date.strftime,
      'scheme 10' => Settings.agfs_fee_reform_release_date.strftime,
      'post agfs reform' => Settings.agfs_fee_reform_release_date.strftime,
      'scheme 9' => '2018-03-31',
      'pre agfs reform' => '2018-03-31',
      'lgfs scheme 11' => Settings.lgfs_scheme_11_feb_2026_release_date.strftime,
      'lgfs scheme 10' => Settings.lgfs_scheme_10_clair_release_date.strftime,
      'lgfs scheme 9a' => '2020-09-17',
      'lgfs scheme 9' => '2022-09-29',
      'lgfs' => '2022-09-29'
    }
  end

  def main_hearing_date_mappings
    {
      'scheme 16' => Settings.agfs_scheme_16_section_twenty_eight_increase.strftime,
      'scheme 15' => Settings.agfs_scheme_15_additional_prep_fee_and_kc.strftime,
      'scheme 13' => Settings.agfs_scheme_13_clair_release_date.strftime,
      'scheme 12a' => Settings.clair_contingency_date.strftime,
      'scheme 12' => Settings.clar_release_date.strftime,
      'scheme 11' => Settings.agfs_scheme_11_release_date.strftime,
      'scheme 10' => Settings.agfs_fee_reform_release_date.strftime,
      'post agfs reform' => Settings.agfs_fee_reform_release_date.strftime,
      'scheme 9' => '2018-03-31',
      'pre agfs reform' => '2018-03-31',
      'lgfs scheme 11' => Settings.lgfs_scheme_11_feb_2026_release_date.strftime,
      'lgfs scheme 10' => Settings.lgfs_scheme_10_clair_release_date.strftime,
      'lgfs scheme 9a' => Settings.clair_contingency_date.strftime,
      'lgfs scheme 9' => '2022-09-29',
      'lgfs' => '2022-09-29'
    }
  end
end
