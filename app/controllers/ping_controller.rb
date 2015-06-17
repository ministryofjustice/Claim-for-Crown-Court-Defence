class PingController  < ApplicationController
  respond_to :json

  def index
      respond_with(
        {
          'Build Number' => ENV['BUILD_NUMBER'] || "Not Avaialble",
          'Build Date'   => ENV['BUILD_DATE'] || 'Not Available',
          'Commit SHA'   => ENV['GIT_COMMIT'] || 'Not Available'
        }
      )
  end
end
