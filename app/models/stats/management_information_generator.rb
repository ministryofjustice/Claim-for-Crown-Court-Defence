require 'csv'

module Stats

  class ManagementInformationGenerator

    def initialize
      @stats_dir = File.join(Rails.root, 'tmp', 'stats')
      FileUtils.mkdir @stats_dir unless File.exist?(@stats_dir)
      @filename = File.join(@stats_dir, "management_information_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}.csv")
    end

    def run
      generate_new_report
      delete_old_reports
    end

  private
    def delete_old_reports
      files = Dir["#{@stats_dir}/**/*"] - [ @filename ]
      FileUtils.rm files
    end

    def generate_new_report
      CSV.open(@filename, "wb") do |csv|
        csv << Settings.claim_csv_headers.map {|header| header.to_s.humanize}
        Claim::BaseClaim.non_draft.find_each do |claim|
          ClaimCsvPresenter.new(claim, 'view').present! do |claim_journeys|
            claim_journeys.each do |claim_journey|
              csv << claim_journey
            end
          end
        end
      end
    end

  end
end