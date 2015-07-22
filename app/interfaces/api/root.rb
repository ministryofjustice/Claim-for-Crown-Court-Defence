require 'grape'
require 'grape-swagger'

module API
  class Root < Grape::API
    mount API::V1::Advocates::Claim
    mount API::V1::Advocates::Defendant
  end
end
