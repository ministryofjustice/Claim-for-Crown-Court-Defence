module FeeReform
  class SearchOffences
    def self.call(filters)
      new(filters).call
    end

    def initialize(filters = {})
      @filters = filters
      fee_scheme_array = @filters[:fee_scheme].split
      @fee_scheme = FeeScheme.find_by(name: fee_scheme_array[0], version: fee_scheme_array[1])
      @offences_table = Offence.arel_table
      @bands_table = OffenceBand.arel_table
      @categories_table = OffenceCategory.arel_table
    end

    def call
      offences = fee_scheme_offences
                 .joins(offence_band: :offence_category)
                 .includes(offence_band: :offence_category)
                 .group('offence_categories.id, offence_bands.id, offences.id')
                 .order('offence_categories.number, offence_bands.number, offences.description')

      offences = offences.where(description_scope(filters[:search_offence])) if filters[:search_offence].present?

      offences = offences.where(categories_table[:id].eq(filters[:category_id])) if filters[:category_id].present?

      offences = offences.where(bands_table[:id].eq(filters[:band_id])) if filters[:band_id].present?

      offences
    end

    private

    attr_reader :filters, :fee_scheme, :offences_table, :bands_table, :categories_table

    def fee_scheme_offences
      Offence.unscoped.send(:"in_scheme_#{fee_scheme.version}")
    end

    def description_scope(description)
      offences_table[:description].matches("%#{description}%")
                                  .or(offences_table[:contrary].matches("%#{description}%"))
                                  .or(bands_table[:description].matches("%#{description}%"))
                                  .or(categories_table[:description].matches("%#{description}%"))
    end
  end
end
