class OffencesSummaryService
  class Row
    delegate :id, to: :@offence

    def initialize(offence, fee_schemes: [])
      @offence = offence
      @fee_schemes = fee_schemes
    end

    def label
      return @offence.offence_class.class_letter if @offence.offence_class_id

      @offence.offence_band.description
    end

    def category
      return @offence.offence_class.description if @offence.offence_class_id

      @offence.offence_band.offence_category.description
    end

    def description(width: nil)
      return @offence.description if width.nil?

      @offence.description[0, width]
    end

    def unique_code(width: nil)
      return @offence.unique_code if width.nil?

      @offence.unique_code[0, width]
    end

    def fee_scheme_flags
      @fee_scheme_flags ||= @fee_schemes.map { |fs| @offence.fee_schemes.include?(fs) }
    end
  end
end
