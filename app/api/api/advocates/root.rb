require 'grape'
require 'grape-swagger'

module API
  module Advocates
    class Root < Grape::API
      mount API::Advocates::V1
    end
  end
end
