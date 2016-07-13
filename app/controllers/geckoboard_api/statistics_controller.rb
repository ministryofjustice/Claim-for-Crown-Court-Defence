class GeckoboardApi::StatisticsController < ApplicationController

  skip_load_and_authorize_resource only: [:index]

  layout 'statistics'

  def index
    @available_reports = {
      'Claim creation by source' => 'claim_creation_source',
      'Claim Submissions' => 'claim_submissions',
      'Requests for further info' => 'requests_for_further_info',
      'Multi session submissions' => 'multi_session_submissions',
      'Time reject to auth' => 'time_reject_to_auth',

      'Completion rate' => 'completion_rate',
      'Time to conpletion' => 'time_to_completion',
    }
  end
end

