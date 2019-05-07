module DateHelper
  def set_date(date_string)
    date = Time.parse(date_string)
    self.day.set date.day.to_s
    self.month.set date.month.to_s
    self.year.set date.year.to_s
  end

  def set_invalid_date
    self.day.set '1'
  end

  def scheme_date_for(text)
    case text&.downcase&.strip
      when 'scheme 11' then
        Settings.agfs_scheme_11_release_date.strftime
      when 'scheme 10' || 'post agfs reform' then
        Settings.agfs_fee_reform_release_date.strftime
      when 'scheme 9' || 'pre agfs reform' then
        "2016-01-01"
      when 'lgfs' then
        "2016-04-01"
      else
        "2016-01-01"
    end
  end
end

World(DateHelper)
