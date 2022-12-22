module FeeSchemeFactory
  class Base
    def self.call(...) = new(...).call

    def initialize(representation_order_date:, main_hearing_date: nil)
      @representation_order_date = representation_order_date&.to_date
      @main_hearing_date = main_hearing_date&.to_date
    end

    def call
      FeeScheme.find_by(name:, version:)
    end

    private

    def version
      filters.each do |filter|
        return filter[:scheme] if filter[:range].include?(@representation_order_date)
      end
    end

    def clair_contingency
      @main_hearing_date && @main_hearing_date >= Settings.clair_contingency_date
    end
  end
end
