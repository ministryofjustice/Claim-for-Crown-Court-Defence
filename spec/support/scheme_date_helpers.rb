module SchemeDateHelpers
  def scheme_date_for(text)
    scheme_date_mappings[text&.downcase&.strip] || '2016-01-01'
  end

  def main_hearing_date_for(text)
    main_hearing_date_mappings[text&.downcase&.strip] || '2016-01-01'
  end

  private

  def scheme_date_mappings
    {
      'scheme 15' => Settings.agfs_scheme_15_additional_prep_fee_and_kc.strftime,
      'scheme 13' => Settings.agfs_scheme_13_clair_release_date.strftime,
      'scheme 12a' => Settings.clar_release_date.strftime,
      'scheme 12' => Settings.clar_release_date.strftime,
      'scheme 11' => Settings.agfs_scheme_11_release_date.strftime,
      'scheme 10' => Settings.agfs_fee_reform_release_date.strftime,
      'post agfs reform' => Settings.agfs_fee_reform_release_date.strftime,
      'scheme 9' => '2016-01-01',
      'pre agfs reform' => '2016-01-01',
      'lgfs scheme 10' => Settings.lgfs_scheme_10_clair_release_date.strftime,
      'lgfs scheme 9a' => '2020-09-17',
      'lgfs scheme 9' => '2016-04-01',
      'lgfs' => '2016-04-01'
    }
  end

  def main_hearing_date_mappings
    {
      'scheme 15' => Settings.agfs_scheme_15_additional_prep_fee_and_kc.strftime,
      'scheme 13' => Settings.agfs_scheme_13_clair_release_date.strftime,
      'scheme 12a' => Settings.clair_contingency_date.strftime,
      'scheme 12' => Settings.clar_release_date.strftime,
      'scheme 11' => Settings.agfs_scheme_11_release_date.strftime,
      'scheme 10' => Settings.agfs_fee_reform_release_date.strftime,
      'post agfs reform' => Settings.agfs_fee_reform_release_date.strftime,
      'scheme 9' => '2016-01-01',
      'pre agfs reform' => '2016-01-01',
      'lgfs scheme 10' => Settings.lgfs_scheme_10_clair_release_date.strftime,
      'lgfs scheme 9a' => Settings.clair_contingency_date.strftime,
      'lgfs scheme 9' => '2016-04-01',
      'lgfs' => '2016-04-01'
    }
  end
end
