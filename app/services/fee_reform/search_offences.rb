module FeeReform
  class SearchOffences
    def self.call(filters)
      new(filters).call
    end

    def initialize(filters = {})
      @filters = filters
      @offences_table = Offence.arel_table
      @bands_table = OffenceBand.arel_table
      @categories_table = OffenceCategory.arel_table
    end

    def call
      offences = Offence.unscoped.in_scheme_ten
                        .joins(offence_band: :offence_category)
                        .includes(offence_band: :offence_category)
                        .group('offences.description, offences.id, offence_bands.id, offence_categories.id')

      offences = offences.where(description_scope(filters[:search_offence])) if filters[:search_offence].present?

      offences
    end

    private

    attr_reader :filters, :offences_table, :bands_table, :categories_table

    def description_scope(description)
      offences_table[:description].matches("%#{description}%")
                                  .or(offences_table[:contrary].matches("%#{description}%"))
                                  .or(bands_table[:description].matches("%#{description}%"))
                                  .or(categories_table[:description].matches("%#{description}%"))
    end
  end
end
