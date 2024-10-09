module API
  module Entities
    class Document < BaseEntity
      expose :uuid, if: ->(instance, _opts) { instance.respond_to?(:uuid) }
      expose :url
      expose :file_name
      expose :size

      private

      def attachment
        object.is_a?(ActiveStorage::Attachment) ? object : object.attachment
      end

      def url
        attachment.first.blob.url(disposition: 'attachment') if attachment.attached?
      end

      def file_name
        attachment.first.filename if attachment.attached?
      end

      def size
        attachment.first.byte_size if attachment.attached?
      end
    end
  end
end
