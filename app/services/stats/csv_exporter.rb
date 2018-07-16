require 'csv'

module Stats
  class CsvExporter
    def self.call(data, options = {})
      new(data, options).call
    end

    def initialize(data, options)
      @data = data
      @headers = options[:headers]
    end

    def call
      CSV.generate do |csv|
        csv << headers if headers.present?
        data.each do |hash|
          csv << hash.values
        end
      end
    end

    private

    attr_reader :data, :headers
  end
end
