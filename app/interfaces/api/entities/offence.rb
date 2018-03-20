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
        expose :offence_class_id, if: ->(instance, _opts) { instance.fee_schemes.first.number.eql?(9) }
        expose :offence_class,
               if: ->(instance, _opts) { instance.fee_schemes.first.number.eql?(9) },
               using: API::Entities::OffenceClass
        expose :fee_band,
               if: ->(instance, _opts) { instance.fee_schemes.first.number.eql?(10) },
               using: API::Entities::FeeBand
      end

      private

      def class_description
        object.offence_class.description
      end
    end
  end
end
