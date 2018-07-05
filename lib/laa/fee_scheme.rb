module LAA
  class FeeScheme
    attr_reader :id, :start_date, :end_date, :supplier_type, :description

    def initialize(options = {})
      @options = options.with_indifferent_access
      @id = @options.fetch(:id)
      @start_date = @options[:start_date]
      @end_date = @options[:end_date]
      @supplier_type = @options[:supplier_type]
      @description = @options[:description]
    end

    class << self
      def find(options)
        filters = { supplier_type: options.fetch(:supplier_type) }
        filters[:case_date] = options[:case_date] if options[:case_date]
        response = api_client.get('/api/v1/fee-schemes/', filters)
        return unless response.success?
        parsed_response = JSON.parse(response.body)
        # TODO: instead of first, define the policy to choose the
        # appropriate fee scheme if there are multiple matches
        fee_scheme_attrs = parsed_response['results'].first
        return unless fee_scheme_attrs
        new(fee_scheme_attrs)
      end

      def api_client
        @api_client ||= LAA::FeeCalculator::API.instance
      end
    end
  end
end
