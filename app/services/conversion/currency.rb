module Conversion
  class Currency
    def self.call(date, value)
      new(date, value).call
    end

    def initialize(date, value)
      @date = date
      @value = value&.delete(',')
    end

    def call
      params = query_options
      result = JSON.parse(RestClient.get('http://apilayer.net/api/historical', params: params)).deep_symbolize_keys
      rate = result[:quotes][:USDGBP]
      (rate * @value.to_f).round(2)
    rescue StandardError => e
      Rails.logger.error "Error converting currency #{e.message}"
      nil
    end

    private

    def query_options
      default_options.merge(date: @date.to_s(:db))
    end

    def default_options
      {
        currencies: 'USD,GBP',
        access_key: Rails.application.secrets.currency_api_key
      }
    end
  end
end
