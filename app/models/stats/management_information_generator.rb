require 'csv'

module Stats

  class ManagementInformationGenerator

    def run
      unless StatsReport.generation_in_progress?('management_information')
        begin
          report_record = Stats::StatsReport.record_start('management_information')
          report_contents = generate_new_report
          report_record.write_report(report_contents)
        rescue => err
          report_contents = "#{err.class} - #{err.message} \n #{err.backtrace}"
          report_record.write_error(report_contents)
          raise err
        end
      end
    end

  private
    def generate_new_report
      csv_string = CSV.generate do |csv|
        csv << Settings.claim_csv_headers.map {|header| header.to_s.humanize}
        Claim::BaseClaim.non_draft.find_each do |claim|
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
