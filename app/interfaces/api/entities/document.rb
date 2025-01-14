module API
  module Entities
    class Document < BaseEntity
      expose :uuid, if: ->(instance, _opts) { instance.respond_to?(:uuid) }
      expose :url
      expose :file_name
      expose :size

      private

      def attachments
        object.is_a?(ActiveStorage::Attachment) ? object : object.attachments
      end

      def url
        attachments.first.blob.url(disposition: 'attachment') if attachments.attached?
      end

      def file_name
        attachments.first.filename if attachments.attached?
      end

      def size
        attachments.first.byte_size if attachments.attached?
      end
    end
  end
end
