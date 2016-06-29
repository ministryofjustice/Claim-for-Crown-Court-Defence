class GeckoboardApi::WidgetsController < GeckoboardApi::ApplicationController
  before_action :set_claim_reporter

  def claims; end

  def claim_completion; end

  def average_processing_time; end

  def claim_submissions
    respond_with_json_payload_from_class(Stats::ClaimSubmissionsDataGenerator)
  end

  def multi_session_submissions
    respond_with_json_payload_from_class(Stats::MultiSessionSubmissionDataGenerator)
  end

  private

  def respond_with_json_payload_from_class(klass)
    respond_to do |format|
      payload = klass.new.run
      format.json { render :json => payload }
    end
  end

  def set_claim_reporter
    @reporter = ClaimReporter.new
  end
end
