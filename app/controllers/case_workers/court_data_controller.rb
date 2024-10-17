module CaseWorkers
  class CourtDataController < CaseWorkers::ApplicationController
    before_action :set_court_data, only: :index

    def index; end

    private

    def set_court_data
      @court_data = CourtData.new(claim_id: params[:claim_id])
    end
  end
end
