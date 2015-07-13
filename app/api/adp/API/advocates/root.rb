require 'grape'
require 'grape-swagger'

module ADP
  module API
    module Advocates
      class Root < Grape::API
        mount ADP::API::Advocates::V1
        add_swagger_documentation
      end
    end
  end
end
