module API
  module Entities
    class BaseEntity < Grape::Entity
      unexpose :created_at, :updated_at

      class << self
        def export_format?
          lambda { |_instance, opts| opts.opts_hash.fetch(:export_format, false) }
        end
      end
    end
  end
end
