require 'rails_helper'
require 'spec_helper'
require 'api_test_client'


describe "API client smoke test" do
  # include ApiTestClient

  it "client should get and post successfully" do
    client_test = ApiTestClient.new()
    expect(client_test.success).to eql(true)
  end

end