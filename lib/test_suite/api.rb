require_relative 'expectation_collection'

module TestSuite 
  class Api < Base
    def initialize
      super(assertion_factory)
    end

    private

    def assertion_factory
      # ApiClient::Info methods
      ApiInfoExpectations.default.map_to_assertions +
      
      # ApiClient::Create methods 
      ApiCreateExpectations.default.map_to_assertions  +

      # ApiClient::Validate methods 
      ApiValidateExpectations.default.map_to_assertions  
    end
  end
end