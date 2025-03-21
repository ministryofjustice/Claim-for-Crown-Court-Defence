module CaseWorkers
  class CourtDataController < CaseWorkers::ApplicationController
    before_action :set_court_data, only: %i[index show]
    skip_load_and_authorize_resource only: %i[show feedback]

    Feedback = Struct.new(:case_number, :claim_id, :defendant_id, :comments)

    def index; end

    def show
      @defendant = @court_data.defendants.find { |defendant| defendant.hmcts&.id == params[:id] }
      redirect_to error_404_url if @defendant.nil?
    end

    private

    def set_court_data
      @court_data = CourtData.new(claim_id: params[:claim_id])
    end

    def set_claim
      @claim = Claim::BaseClaim.find(params[:claim_id])
    end
  end
end
