module SchemeDateHelpers
  def scheme_date_for(text)
    case text&.downcase&.strip
      when 'scheme 12' then
        Settings.clar_release_date.strftime
      when 'scheme 11' then
        Settings.agfs_scheme_11_release_date.strftime
      when 'scheme 10' || 'post agfs reform' then
        Settings.agfs_fee_reform_release_date.strftime
      when 'scheme 9' || 'pre agfs reform' then
        '2016-01-01'
      when 'lgfs' then
        '2016-04-01'
      else
        '2016-01-01'
    end
  end
end
