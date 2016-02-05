require 'csv'

class CaseWorkers::Admin::ManagementInformationController < CaseWorkers::Admin::ApplicationController
  skip_load_and_authorize_resource only: [:index, :report]
  before_action -> { authorize! :view, :management_information }, only: [:index, :report]
  before_action :set_claims, only: :report

  def index

  end

  def report
    respond_to do |format|
      format.csv { send_data csv_report, filename: "all_claims_report.csv" }
    end
  end

  private

  def csv_report
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

  def set_claims
    @claims = Claim::BaseClaim.non_draft
  end

end
