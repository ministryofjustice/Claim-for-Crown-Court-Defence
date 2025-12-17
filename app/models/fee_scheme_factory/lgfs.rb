module FeeSchemeFactory
  class LGFS < Base
    private

    def name = 'LGFS'

    def filters
      @filters ||= [
        { scheme: 9, range: scheme_nine_range },
        { scheme: 10, range: scheme_ten_range },
        { scheme: 11, range: scheme_eleven_range }
      ]
    end

    def scheme_nine_range
      return Date.parse('1 April 2012')..(Settings.clar_release_date - 1.day) if clair_contingency

      Date.parse('1 April 2012')..(Settings.lgfs_scheme_10_clair_release_date - 1.day)
    end

    def scheme_ten_range
      return (Settings.clar_release_date..Time.zone.today) if clair_contingency

      Settings.lgfs_scheme_10_clair_release_date..(Settings.lgfs_scheme_11_csfr - 1.day)
    end

    def scheme_eleven_range
      Settings.lgfs_scheme_11_csfr..Time.zone.today
    end
  end
end
