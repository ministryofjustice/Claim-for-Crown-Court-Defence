class FeeSchemeManager
  DEFAULT_LGFS_FEE_SCHEME = :lgfs_v6
  DEFAULT_AGFS_FEE_SCHEME = :agfs_v9

  AGFS_FEE_SCHEME_10_DATE = Date.new(2017, 1, 1)

  class << self
    def version(claim)
      case claim.class.to_s
      when 'Claim::AdvocateClaim'
        get_agfs_version(claim.earliest_representation_order_date)
      else
        get_lgfs_version
      end
    end

    private

    def get_lgfs_version
      DEFAULT_LGFS_FEE_SCHEME
    end

    def get_agfs_version(date)
      if date.nil? || RailsHost.gamma?
        DEFAULT_AGFS_FEE_SCHEME
      else
        agfs_version_by_date(date)
      end
    end

    def agfs_version_by_date(date)
      if date < AGFS_FEE_SCHEME_10_DATE
        DEFAULT_AGFS_FEE_SCHEME
      else
        :agfs_v10
      end
    end
  end
end
