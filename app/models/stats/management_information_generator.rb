require 'csv'

module Stats
  class ManagementInformationGenerator
    REPORT_NAME = 'management_information'.freeze

    def run
      StatsReport.clean_up(REPORT_NAME)
      return if StatsReport.generation_in_progress?(REPORT_NAME)
      report_record = Stats::StatsReport.record_start(REPORT_NAME)
      report_contents = generate_new_report
      report_record.write_report(report_contents)
    rescue StandardError => err
      report_contents = "#{err.class} - #{err.message} \n #{err.backtrace}"
      report_record.write_error(report_contents)
      send_slack_message(report_record) if ENV['ENV'].eql?('gamma')
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

    def send_slack_message(report_record)
      slack = SlackNotifier.new('cccd_development')
      slack.build_generic_payload(':robot_face:',
                                  "MI Generation failed on #{ENV['ENV']}",
                                  "#{report_record.report} \n Stats::StatsReport.id: #{report_record.id}",
                                  false)
      slack.send_message!
    end
  end
end
