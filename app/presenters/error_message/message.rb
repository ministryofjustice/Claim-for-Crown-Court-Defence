#
# Class to represent a single custom error message with
# its variants of long, short and api.
#
module ErrorMessage
  class Message
    include ErrorMessage::Helper

    def initialize(long, short, api, key)
      @long = long
      @short = short
      @api = api
      @key = key
    end

    def long
      substitute_submodel_numbers_and_names(@long, @key)
    end

    def short
      substitute_submodel_numbers_and_names(@short, @key)
    end

    def api
      substitute_submodel_numbers_and_names(@api, @key)
    end
  end
end
