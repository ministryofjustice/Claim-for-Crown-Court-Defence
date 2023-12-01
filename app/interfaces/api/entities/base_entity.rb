module API
  module Entities
    class BaseEntity < Grape::Entity
      unexpose :created_at, :updated_at

      class << self
        def export_format?
          ->(_instance, opts) { opts.opts_hash.fetch(:export_format, false) }
        end
      end

      def length_or_one(length)
        [length, 1].compact.max
      end
    end
  end
end
