require_relative 'api_helper'

module API
  module Helpers
    class GrapeAPIHelper < Grape::API
      include API::Helpers::APIHelper
    end
  end
end
