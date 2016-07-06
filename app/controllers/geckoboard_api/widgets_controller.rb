class GeckoboardApi::WidgetsController < GeckoboardApi::ApplicationController
  before_action :set_claim_reporter

  def claims; end

  def claim_completion; end

  def average_processing_time; end

  def claim_creation_source
    respond_with_json_payload_from_class(Stats::ClaimCreationSourceDataGenerator)
  end

  def claim_submissions
    respond_with_json_payload_from_class(Stats::ClaimSubmissionsDataGenerator)
  end

  def multi_session_submissions
    respond_with_json_payload_from_class(Stats::MultiSessionSubmissionDataGenerator)
  end

  def requests_for_further_info
    respond_with_json_payload_from_class(Stats::RequestForFurtherInfoDataGenerator)
  end

  def time_reject_to_auth
    respond_with_json_payload_from_class(Stats::TimeFromRejectToAuthDataGenerator)
  end

  def completion_rate
    respond_with_json_payload_from_class(Stats::CompletionRateDataGenerator)
  end

  def time_to_completion
    respond_with_json_payload_from_class(Stats::TimeToCompletionDataGenerator)
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
