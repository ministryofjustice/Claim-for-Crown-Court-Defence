require 'court_data_adaptor/resource/base'
require 'court_data_adaptor/resource/offence'

module CourtDataAdaptor
  module Resource
    class Defendant < Base
      has_many :offences

      property :id, type: :string
      property :prosecution_case_reference, type: :string
      property :name, type: :string
      property :date_of_birth, type: :string
      property :maat_reference, type: :string
      property :user_name
      property :unlink_reason_code
      property :unlink_reason_text
    end
  end
end
