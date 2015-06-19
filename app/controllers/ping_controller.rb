class PingController  < ApplicationController
  respond_to :json

  def index
      respond_with(
        {
          'version_number'  => ENV['VERSION_NUMBER'] || "Not Avaialble",
          'build_date'      => ENV['BUILD_DATE'] || 'Not Available',
          'commit_id'       => ENV['COMMIT_ID'] || 'Not Available',
          'build_tag'       => ENV['BUILD_TAG'] || "Not Available"
        }
      )
  end
end
