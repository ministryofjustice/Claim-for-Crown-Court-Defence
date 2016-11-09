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
        expose :offence_class_id
        expose :offence_class, using: API::Entities::OffenceClass
      end

      private

      def class_description
        object.offence_class.description
      end
    end
  end
end
