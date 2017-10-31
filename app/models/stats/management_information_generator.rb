require 'csv'

module Stats
  class ManagementInformationGenerator
    REPORT_NAME = 'management_information'.freeze

    def run
      StatsReport.clean_up(REPORT_NAME)
      unless StatsReport.generation_in_progress?(REPORT_NAME)
        report_record = Stats::StatsReport.record_start(REPORT_NAME)
        report_contents = generate_new_report
        report_record.write_report(report_contents)
      end
    rescue StandardError => err
      report_contents = "#{err.class} - #{err.message} \n #{err.backtrace}"
      report_record.write_error(report_contents)
      raise err
    end

    private

    def generate_new_report
      csv_string = CSV.generate do |csv|
        csv << Settings.claim_csv_headers.map { |header| header.to_s.humanize }
        Claim::BaseClaim.active.non_draft.find_each do |claim|
          ClaimCsvPresenter.new(claim, 'view').present! do |claim_journeys|
            claim_journeys.each do |claim_journey|
              csv << claim_journey
            end
          end
        end
      end
      csv_string
    end
  end
end
