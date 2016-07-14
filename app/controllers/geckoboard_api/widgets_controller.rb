class GeckoboardApi::WidgetsController < GeckoboardApi::ApplicationController
  before_action :set_claim_reporter

  layout 'statistics'

  def claims; end

  def claim_completion; end

  def average_processing_time; end

  def claim_creation_source
    respond_payload_from_class(Stats::ClaimCreationSourceDataGenerator)
  end

  def claim_submissions
    respond_payload_from_class(Stats::ClaimSubmissionsDataGenerator)
  end

  def multi_session_submissions
    respond_payload_from_class(Stats::MultiSessionSubmissionDataGenerator)
  end

  def requests_for_further_info
    respond_payload_from_class(Stats::RequestForFurtherInfoDataGenerator)
  end

  def time_reject_to_auth
    respond_payload_from_class(Stats::TimeFromRejectToAuthDataGenerator)
  end

  def completion_rate
    respond_payload_from_class(Stats::CompletionRateDataGenerator)
  end

  def time_to_completion
    respond_payload_from_class(Stats::TimeToCompletionDataGenerator)
  end

  def redeterminations_average
    respond_payload_from_class(Stats::ClaimRedeterminationsDataGenerator)
  end

  private

  def respond_payload_from_class(klass)
    respond_to do |format|
      @payload = klass.new.run
      format.json { render :json => @payload.to_json }
      format.html
    end
  end

  def set_claim_reporter
    @reporter = ClaimReporter.new
  end
end
