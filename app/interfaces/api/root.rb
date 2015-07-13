require 'grape'
require 'grape-swagger'

module API

  class Root < Grape::API
    use API::Logger
    mount API::V1::Advocates::Claim
  end
end
