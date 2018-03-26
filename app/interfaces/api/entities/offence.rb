module API
  module Entities
    class Offence < BaseEntity
      expose :export_format, merge: true, if: export_format? do
        expose :description, as: :category
        expose :class_description, as: :class
      end

      expose :full_format, merge: true, unless: export_format? do
        expose :id
        expose :description
        expose :offence_class_id, if: ->(instance, _opts) { instance.scheme_nine? }
        expose :offence_class,
               if: ->(instance, _opts) { instance.scheme_nine? },
               using: API::Entities::OffenceClass
        expose :offence_band,
               if: ->(instance, _opts) { !instance.scheme_nine? },
               using: API::Entities::OffenceBand
      end

      private

      def class_description
        object.offence_class.description
      end
    end
  end
end
