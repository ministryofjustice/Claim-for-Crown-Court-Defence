require 'grape'
require 'grape-swagger'

module API
  class Root < Grape::API
    mount API::V1::Advocates::Claim
  end
end
