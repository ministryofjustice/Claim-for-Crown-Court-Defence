class GeckoboardApi::WidgetsController < GeckoboardApi::ApplicationController
  before_action :set_claim_reporter

  def claims
  end

  def claim_completion
  end

  private

  def set_claim_reporter
    @reporter = ClaimReporter.new
  end
end
