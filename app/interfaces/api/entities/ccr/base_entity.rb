module API
  module Entities
    module CCR
      class BaseEntity < Grape::Entity
        unexpose :created_at, :updated_at

        class << self
          def export_format?
            ->(_instance, opts) { opts.opts_hash.fetch(:export_format, false) }
          end
        end
      end
    end
  end
end
