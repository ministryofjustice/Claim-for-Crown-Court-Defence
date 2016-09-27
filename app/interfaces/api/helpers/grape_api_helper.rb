require_relative 'api_helper'

module API
  class Error < StandardError; end
  class ArgumentError < Error; end

  module Helpers
    class GrapeApiHelper < Grape::API
      include API::Helpers::ApiHelper
    end
  end
end
