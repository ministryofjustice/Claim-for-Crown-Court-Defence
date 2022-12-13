module FeeSchemeFactory
  class LGFS < Base
    private

    def name = 'LGFS'

    def version
      case @representation_order_date
      when lgfs_scheme_nine_range
        9
      when lgfs_scheme_ten_range
        10
      end
    end

    def lgfs_scheme_nine_range
      return Date.parse('1 April 2012')..(Settings.clar_release_date - 1.day) if clair_contingency

      Date.parse('1 April 2012')..(Settings.lgfs_scheme_10_clair_release_date - 1.day)
    end

    def lgfs_scheme_ten_range
      return (Settings.clar_release_date..) if clair_contingency

      Settings.lgfs_scheme_10_clair_release_date..
    end
  end
end
