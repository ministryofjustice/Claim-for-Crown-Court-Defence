module LAA
  class Fee
    attr_reader :amount

    def initialize(amount)
      @amount = amount
    end

    class << self
      def calculate(options)
        scheme_pk = options.fetch(:fee_scheme_id)
        filters = {
          fee_type_code: options.fetch(:fee_type_code),
          scenario: options.fetch(:scenario_id)
        }

        %i[advocate_type offence_class day number_of_cases number_of_defendants trial_length pw ppe case defendant
           fixed halfday hour month pages_of_prosecuting_evidence retrial_interval].each do |field|
          filters[field] = options[field] if options[field]
        end

        puts filters.inspect

        response = api_client.get("/api/v1/fee-schemes/#{scheme_pk}/calculate/", filters)
        puts response.body.inspect
        return unless response.success?
        parsed_response = JSON.parse(response.body)
        amount = parsed_response['amount']
        return unless amount
        new(amount.to_f)
      end

      def api_client
        @api_client ||= LAA::FeeCalculator::API.instance
      end
    end
  end
end
