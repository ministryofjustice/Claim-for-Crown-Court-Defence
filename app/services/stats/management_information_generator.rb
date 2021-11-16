require 'csv'

module Stats
  class ManagementInformationGenerator
    include StuffLogger

    def self.call(**kwargs)
      new(kwargs).call
    end

    def initialize(**kwargs)
      @format = kwargs.fetch(:format, :csv)
      @scheme = kwargs.fetch(:scheme, :all)
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
      Claim::BaseClaim.active.non_draft.send(@scheme)
    end

    # TODO: separate data retrieval from exporting the data itself
    # keeping existent behaviour for now
    def generate_new_report
      log_info('MI Report generation started...')
      content = CSV.generate do |csv|
        csv << headers
        claims.find_each do |claim|
          ManagementInformationPresenter.new(claim, 'view').present! do |claim_journeys|
            claim_journeys.each { |journey| csv << journey } if claim_journeys.any?
          end
        end
      end
      log_info('MI Report generation finished')
      content
    rescue StandardError => e
      log_error(e, 'MI Report generation error')
    end
  end
end
