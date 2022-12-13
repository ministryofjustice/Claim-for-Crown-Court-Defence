module FeeSchemeFactory
  class AGFS < Base
    private

    def name = 'AGFS'

    def version
      case @representation_order_date
      when agfs_scheme_nine_range
        9
      when agfs_scheme_ten_range
        10
      when agfs_scheme_eleven_range
        11
      when agfs_scheme_twelve_range
        12
      when agfs_scheme_thirteen_range
        13
      end
    end

    def agfs_scheme_nine_range = Date.parse('1 April 2012')..(Settings.agfs_fee_reform_release_date - 1.day)

    def agfs_scheme_ten_range = Settings.agfs_fee_reform_release_date..(Settings.agfs_scheme_11_release_date - 1.day)

    def agfs_scheme_eleven_range = Settings.agfs_scheme_11_release_date..(Settings.clar_release_date - 1.day)

    def agfs_scheme_twelve_range
      return false if clair_contingency

      Settings.clar_release_date..(Settings.agfs_scheme_13_clair_release_date - 1.day)
    end

    def agfs_scheme_thirteen_range
      (return Settings.clar_release_date..) if clair_contingency

      Settings.agfs_scheme_13_clair_release_date..
    end
  end
end
