module API
  module Entities
    class Document < BaseEntity
      expose :uuid, if: ->(instance, _opts) { instance.respond_to?(:uuid) }

      private

      def attachment
        object.is_a?(ActiveStorage::Attachment) ? object : object.attachment
      end
    end
  end
end
