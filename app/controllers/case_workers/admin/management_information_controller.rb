require 'csv'

class CaseWorkers::Admin::ManagementInformationController < CaseWorkers::Admin::ApplicationController
  skip_load_and_authorize_resource only: [:index, :report]
  before_filter(only: [:index, :report]) { authorize! if can? :view, :management_information }

  def index

  end

  def report
    respond_to do |format|
      format.csv do
        send_data ClaimReportGenerator.generate!, filename: "report.csv"
      end
    end
  end
end
