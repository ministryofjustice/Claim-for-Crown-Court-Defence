require_relative 'api_helper'

module API
  module Helpers
    class GrapeApiHelper < Grape::API
      include API::Helpers::ApiHelper
    end
  end
end
