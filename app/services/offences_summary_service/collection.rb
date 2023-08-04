class OffencesSummaryService
  class Collection
    include Enumerable

    def initialize(offences:, fee_schemes:)
      @rows = offences.map do |offence|
        Row.new(offence, fee_schemes:)
      end
      @fee_schemes = fee_schemes
    end

    def each(&) = @rows.each(&)

    def fee_scheme_headings = @fee_scheme_headings = @fee_schemes.map { |fs| format('%s %d', fs.name, fs.version) }
  end
end
