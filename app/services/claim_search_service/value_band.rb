class ClaimSearchService
  class ValueBand < Base
    def initialize(search, value_band_id:)
      super

      @value_band_id = value_band_id
    end

    def run
      @search.run.where(value_band_id: @value_band_id)
    end

    def self.decorate(search, value_band_id: nil, **_params)
      # N.B. Originally a zero value_band_id would result in a where.not(value_band_id: nil) but this doesn't seem to
      # have any effect
      return search if value_band_id.blank? || value_band_id.zero?

      new(search, value_band_id: value_band_id)
    end
  end
end
