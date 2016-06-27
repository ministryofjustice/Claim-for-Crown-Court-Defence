class GeckoboardApi::WidgetsController < GeckoboardApi::ApplicationController
  before_action :set_claim_reporter

  def claims; end

  def claim_completion; end

  def average_processing_time; end

  def claim_submissions
    respond_to do |format|
      payload = Stats::ClaimSubmissionsDataGenerator.new.run
      format.json { render :json => payload }
    end
  end

  private

  def set_claim_reporter
    @reporter = ClaimReporter.new
  end
end
