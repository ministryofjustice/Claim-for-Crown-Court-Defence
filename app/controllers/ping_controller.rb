class PingController  < ApplicationController
  respond_to :json

  def index
    Rails.logger.silence do
      respond_with(
        {
          'Build Number' => ENV['BUILD_NUMBER'] || "Not Avaialble",
          'Commit SHA'   => ENV['GIT_COMMIT'] || 'Not Available'
        }
      )
    end
  end
end