require 'csv'

class CaseWorkers::Admin::ManagementInformationController < CaseWorkers::Admin::ApplicationController
  skip_load_and_authorize_resource only: [:index, :download, :generate]
  before_action -> { authorize! :view, :management_information }, only: [:index, :download, :generate]

  def index
    @filename = Stats::ManagementInformationGenerator.current_csv_filename
    @time_generated = Stats::ManagementInformationGenerator.creation_time(@filename) unless @filename.nil?
  end

  def download
    @filename = Stats::ManagementInformationGenerator.current_csv_filename
    send_file @filename, type: 'text/csv; charset=iso-8859-1; header=present'
  end

  def generate
    ManagemenInformationGenerationJob.perform_later
    redirect_to case_workers_admin_management_information_url, alert: 'A background job has been scheduled to regenerate the Management Information report.  Please refresh this page in a few minutes.'
  end

  private

  def csv_report
    @claims = Claim::BaseClaim.non_draft
    CSV.generate(headers: true) do |csv|
      csv << Settings.claim_csv_headers.map {|header| header.to_s.humanize}
      @claims.each do |claim|
        ClaimCsvPresenter.new(claim, 'view').present! do |claim_journeys|
          claim_journeys.each do |claim_journey|
            csv << claim_journey
          end
        end
      end
    end
  end

end
