require 'court_data_adaptor/resource/base'
require 'court_data_adaptor/resource/defendant'
# require 'court_data_adaptor/resource/hearing'

module CourtDataAdaptor
  module Resource
    class ProsecutionCase < Base
      has_many :defendants
      # has_many :hearings

      property :prosecution_case_reference
    end
  end
end
