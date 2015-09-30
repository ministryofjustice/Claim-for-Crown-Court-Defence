class GeckoboardApi::WidgetsController < GeckoboardApi::ApplicationController
  def claims
    @reporter = ClaimReporter.new
  end
end
