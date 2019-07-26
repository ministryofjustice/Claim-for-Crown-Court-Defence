require 'csv'

module Stats
  class ManagementInformationGenerator
    DEFAULT_FORMAT = 'csv'.freeze

    def self.call(options = {})
      new(options).call
    end

    def initialize(options = {})
      @format = options.fetch(:format, DEFAULT_FORMAT)
    end

    def call
      output = generate_new_report
      Stats::Result.new(output, format)
    end

    private

    attr_reader :format

    def log_error(error)
      LogStuff.send(:error,
                    self.class.name,
                    error_message: "#{error.class} - #{error.message}",
                    error_backtrace: error.backtrace.inspect.to_s) do
                      'MI Report generation error'
                    end
    end

    def log_info(message)
      LogStuff.send(:info, message)
    end

    def headers
      Settings.claim_csv_headers.map { |header| header.to_s.humanize }
    end

    def active_non_draft_claims
      Claim::BaseClaim.active.non_draft
    end

    # TODO: separate data retrieval from exporting the data itself
    # keeping existent behaviour for now
    def generate_new_report
      log_info('Report generation started...')
      CSV.generate do |csv|
        csv << headers
        active_non_draft_claims.find_each do |claim|
          log_info("Adding claim to report with id: #{claim.id} ...")
          ClaimCsvPresenter.new(claim, 'view').present! do |claim_journeys|
            if claim_journeys.any?
              log_info("Adding journey for claim: #{claim.id}")
              claim_journeys.each { |journey| csv << journey }
            end
          end
        end
      end
    rescue StandardError => e
      log_error(e)
    end
  end
end
