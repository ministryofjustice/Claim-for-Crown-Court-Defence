module API
  module Entities
    class BaseEntity < Grape::Entity
      unexpose :created_at, :updated_at

      class << self
        def basic_format?
          lambda { |_instance, opts| opts.opts_hash.fetch(:basic_format, false) }
        end
      end
    end
  end
end
