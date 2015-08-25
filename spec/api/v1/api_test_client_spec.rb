require 'rails_helper'
require 'spec_helper'
require 'api_test_client'

describe ApiTestClient do
#TODO - need tot either set the current enviroment to test or the
# API enviroment to development as currently posts to the API
# are created in dev and therefore the clean up of data is not possible
# from this file (i.e. it cannot find the record created)

  before { Rails.env = 'development' }
  after  { Rails.env = 'test' }
 it "should GET and POST successfully" do

    ap "claim count: " + Claim.count.to_s
    api_client = ApiTestClient.new()
    api_client.run
    # ap api_client.success
    # ap api_client.messages
    ap api_client.errors
    ap api_client.full_error_messages
    expect(api_client.success).to eql(true)
    expect(api_client.failure).to eql(false)
    expect(api_client.messages).to_not be_empty
    expect(api_client.errors).to be_empty

  end

end

describe "api:smoke_test" do

  xit "successful smoke test should exit with 0" do
  end

  xit "failed smoke test should exit with 1" do
  end

end