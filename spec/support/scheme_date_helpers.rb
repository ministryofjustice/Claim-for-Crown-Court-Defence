module SchemeDateHelpers
  def scheme_date_for(text)
    case text&.downcase&.strip
    when 'scheme 13'
      Settings.agfs_scheme_13_clair_release_date.strftime
    when 'scheme 12a'
      Settings.clair_contingency_date.strftime
    when 'scheme 12'
      Settings.clar_release_date.strftime
    when 'scheme 11'
      Settings.agfs_scheme_11_release_date.strftime
    when 'scheme 10' || 'post agfs reform'
      Settings.agfs_fee_reform_release_date.strftime
    when 'scheme 9' || 'pre agfs reform'
      '2016-01-01'
    when 'lgfs scheme 10'
      Settings.lgfs_scheme_10_clair_release_date.strftime
    when 'lgfs' || 'lgfs scheme 9'
      '2016-04-01'
    else
      '2016-01-01'
    end
  end
end
