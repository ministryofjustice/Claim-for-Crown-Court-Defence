module Messaging
  class ProducerResponse
    attr_accessor :code, :body, :description

    def initialize(code:, body:, description:)
      self.code = code
      self.body = body
      self.description = description
    end

    def success?
      (200..201).include?(code)
    end

    def error?
      !success?
    end
  end
end
