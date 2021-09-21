require 'csv'

module Stats
  class ManagementInformationGenerator
    DEFAULT_FORMAT = 'csv'.freeze

    def self.call(options = {})
      new(options).call
    end

    def initialize(options = {})
      @format = options.fetch(:format, DEFAULT_FORMAT)
      @claim_scope = options.fetch(:claim_scope, :all)
    end

    def call
      output = generate_new_report
      Stats::Result.new(output, format)
    end

    private

    attr_reader :format

    def headers
      Settings.claim_csv_headers.map { |header| header.to_s.humanize }
    end

    def claims
      Claim::BaseClaim.active.non_draft.send(@claim_scope)
    end

    # TODO: separate data retrieval from exporting the data itself
    # keeping existent behaviour for now
    def generate_new_report
      log_info('Report generation started...')
      content = CSV.generate do |csv|
        csv << headers
        claims.find_each do |claim|
          ManagementInformationPresenter.new(claim, 'view').present! do |claim_journeys|
            claim_journeys.each { |journey| csv << journey } if claim_journeys.any?
          end
        end
      end
      log_info('Report generation finished')
      content
    rescue StandardError => e
      log_error(e)
    end

    def log_error(error)
      LogStuff.error(class: self.class.name,
                     action: caller_locations(1, 1)[0].label,
                     error_message: "#{error.class} - #{error.message}",
                     error_backtrace: error.backtrace.inspect.to_s) do
                       'MI Report generation error'
                     end
    end

    def log_info(message)
      LogStuff.info(class: self.class.name, action: caller_locations(1, 1)[0].label) { message }
    end
  end
end
