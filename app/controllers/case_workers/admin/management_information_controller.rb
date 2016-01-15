require 'csv'

class CaseWorkers::Admin::ManagementInformationController < CaseWorkers::Admin::ApplicationController
  skip_load_and_authorize_resource only: [:index, :report]
  before_action -> { authorize! :view, :management_information }, only: [:index, :report]
  before_action :set_claims, only: :report

  def index

  end

  def report
    respond_to do |format|
      format.csv { send_data csv_report, filename: "report.csv" }
    end
  end

  private

  def csv_report
    CSV.generate(headers: true) do |csv|
      csv << Settings.csv_column_names.map { |h| h.to_s.humanize }
      @claims.each do |claim|
        csv << ClaimCsvPresenter.new(claim, 'view').present!
      end
    end
  end

  def set_claims
    @claims = Claim.non_draft
  end

end
