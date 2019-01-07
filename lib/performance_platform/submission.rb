module PerformancePlatform
  class Submission
    attr_reader :data_sets

    def initialize(report)
      @values = { service: PerformancePlatform.configuration.service }
      @report_opts = report
      @data_sets = []
      @ready_to_send = false
    end

    def add_data_set(time_stamp, fields = {})
      raise "Fields submitted do not match required fields for #{@report_opts[:type]}" unless report_matches?(fields)

      params = {
        _timestamp: time_stamp.strftime('%Y-%m-%dT00:00:00+00:00'),
        service: @values[:service],
        period: @report_opts[:period],
        report: @report_opts[:type]
      }
      params.merge!(fields)
      @data_sets << DataSet.new(params).payload
      @ready_to_send = true
    rescue StandardError => e
      @ready_to_send = false
      raise e
    end

    def send_data!
      raise 'Unable to send without payload' unless @ready_to_send

      RestClient.post(url, @data_sets.to_json, headers)
    rescue RestClient::ExceptionWithResponse => e
      e.response.body
    end

    private

    def headers
      { content_type: :json, authorization: "Bearer #{@report_opts[:token]}" }
    end

    def url
      UrlBuilder.for_type(@report_opts[:type])
    end

    def report_matches?(fields)
      @report_opts[:fields].sort == fields.keys.sort
    end
  end
end
