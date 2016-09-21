module Remotes
  class RemoteCaseType < RemoteObject

    @@case_types = nil

    def self.all
      @@case_types ||= get_case_types
    end

    def self.lgfs
      all.select { | ct| ct.roles.include?('lgfs') }
    end

    def self.agfs
      all.select { |ct| ct.roles.include?('agfs') }
    end

    def self.interims
      all.select { |ct| ct.roles.include?('interim') }
    end

    def self.find(id)
      all.detect { |ct| ct.id == id }
    end

    private

    def self.get_case_types
      case_types_hash_array = api_get('case_types')
      ostructs = case_types_hash_array.map{ |hash| OpenStruct.new(hash) }

      # Add ** as a temporary measure so that we can easily see in the UI that it is using the API to get data, not the DB
      ostructs.map{ |s| s.name += '**' }
      ostructs
    end

  end
end
