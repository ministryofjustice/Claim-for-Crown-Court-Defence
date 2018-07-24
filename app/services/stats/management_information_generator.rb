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

    # TODO: separate data retrieval from exporting the data itself
    # keeping existent behaviour for now
    def generate_new_report
      CSV.generate do |csv|
        csv << Settings.claim_csv_headers.map { |header| header.to_s.humanize }
        Claim::BaseClaim.active.non_draft.find_each do |claim|
          ClaimCsvPresenter.new(claim, 'view').present! do |claim_journeys|
            if claim_journeys.any?
              claim_journeys.each do |claim_journey|
                csv << claim_journey
              end
            end
          end
        end
      end
    end
  end
end
