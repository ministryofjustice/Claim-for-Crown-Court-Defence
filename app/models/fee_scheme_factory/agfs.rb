module FeeSchemeFactory
  class AGFS < Base
    private

    def name = 'AGFS'

    def filters
      @filters ||= [
        { scheme: 9, range: Date.parse('1 April 2012')..(Settings.agfs_fee_reform_release_date - 1.day) },
        { scheme: 10, range: Settings.agfs_fee_reform_release_date..(Settings.agfs_scheme_11_release_date - 1.day) },
        { scheme: 11, range: Settings.agfs_scheme_11_release_date..(Settings.clar_release_date - 1.day) },
        { scheme: 12, range: scheme_twelve_range },
        { scheme: 13, range: scheme_thirteen_range },
        { scheme: 14, range: scheme_fourteen_range }
      ]
    end

    def scheme_twelve_range
      return [] if clair_contingency

      Settings.clar_release_date..(Settings.agfs_scheme_13_clair_release_date - 1.day)
    end

    def scheme_thirteen_range
      (return Settings.clar_release_date..Settings.agfs_scheme_14_section_twenty_eight - 1.day) if clair_contingency

      Settings.agfs_scheme_13_clair_release_date..Settings.agfs_scheme_14_section_twenty_eight - 1.day
    end

    def scheme_fourteen_range
      Settings.agfs_scheme_14_section_twenty_eight..Time.zone.today
    end
  end
end
