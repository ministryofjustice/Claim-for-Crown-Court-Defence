module CaseWorkers
  class CourtDataController < CaseWorkers::ApplicationController
    before_action :set_court_data, only: :index
    skip_load_and_authorize_resource only: :feedback

    Feedback = Struct.new(:case_number, :claim_id, :comments)

    def index; end

    def feedback
      response = SurveyMonkeySender::CourtData.call(feedback_answers)

      if response[:success]
        redirect_to case_workers_claim_court_data_index_path(params[:claim_id]), notice: response[:response_message]
      else
        redirect_to case_workers_claim_court_data_index_path(params[:claim_id]), alert: response[:response_message]
      end
    end

    private

    def set_court_data
      @court_data = CourtData.new(claim_id: params[:claim_id])
    end

    def set_claim
      @claim = Claim::BaseClaim.find(params[:claim_id])
    end

    def feedback_answers = Feedback.new(params[:case_number], params[:claim_id], params[:comments])
  end
end
