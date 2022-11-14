module Claims
  class ValueBands
    Struct.new('ValueBandDefinition', :id, :name, :minimum, :maximum)

    VALUE_BANDS = {
      10 => Struct::ValueBandDefinition.new(10, '£30,000 or less', 0.0, 30_000.0),
      20 => Struct::ValueBandDefinition.new(20, '£30,000.01 - £115,000', 30_000.01, 115_000.0),
      30 => Struct::ValueBandDefinition.new(30, '£115,000.01 - £175,000', 115_000.01, 175_000.0),
      40 => Struct::ValueBandDefinition.new(40, 'more than £175,000', 175_000.01, 99_999_999.99)
    }.freeze

    def self.band_id_for_claim(claim)
      band_id_for_value(claim.total + claim.vat_amount)
    end

    def self.band_id_for_value(value)
      VALUE_BANDS.each do |band_id, band|
        next if value > band.maximum
        return band_id
      end
      raise 'Maximum band value exceeded'
    end

    def self.band_by_id(band_id)
      VALUE_BANDS[band_id]
    end

    def self.bands
      VALUE_BANDS.values
    end

    def self.band_ids
      VALUE_BANDS.keys
    end

    def self.collection_select
      [Struct::ValueBandDefinition.new(0, 'All Claims', nil, nil)] + bands
    end
  end
end
