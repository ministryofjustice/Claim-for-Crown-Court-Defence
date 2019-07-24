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
      begin
        LogStuff.send(:info, "Report generation started...")
        CSV.generate do |csv|
          LogStuff.send(:info, "Adding CSV headers...")
          csv << Settings.claim_csv_headers.map { |header| header.to_s.humanize }
          LogStuff.send(:info, "Adding CSV headers complete")

          LogStuff.send(:info, "Adding non-draft claim data to CSV...")
          Claim::BaseClaim.active.non_draft.find_each do |claim|

            LogStuff.send(:info, "Adding claim with id: #{claim.id} ...")
            ClaimCsvPresenter.new(claim, 'view').present! do |claim_journeys|
              if claim_journeys.any?

                LogStuff.send(:info, "Using ClaimCsvPresenter for claim: #{claim.id} to add journey to csv report.")
                claim_journeys.each do |claim_journey|
                  csv << claim_journey
                end
                LogStuff.send(:info, "claim_journeys for claim: #{claim.id} to added to csv")

              end
            end
            LogStuff.send(:info, "Adding claim with id: #{claim.id} complete")

          end
        end
        LogStuff.send(:info, "Report generation finished.")

      rescue StandardError => e
        LogStuff.send(:error, "Report generation error has occured:")
        LogStuff.send(:error, "#{e.message}")
        LogStuff.send(:error, "#{e.backtrace.inspect}")
      end
    end
  end
end
