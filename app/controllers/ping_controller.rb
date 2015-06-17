class PingController  < ApplicationController
  respond_to :json

  def index
    Rails.logger.silence do
      respond_with(
        {
          'Build Number' => ENV['BUILD_NUMBER'] || "Not Avaialble",
          'Build Date'   => ENV['BUILD_ID'] || 'Not Available',
          'Commit SHA'   => ENV['GIT_COMMIT'] || 'Not Available'
        }
      )
    end
  end
end
