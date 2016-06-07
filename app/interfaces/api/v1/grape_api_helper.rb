require_relative 'api_helper'

module API
  module V1
    class Error < StandardError; end
    class ArgumentError < Error; end

    class GrapeApiHelper < Grape::API
      include API::V1::ApiHelper
    end
  end
end

