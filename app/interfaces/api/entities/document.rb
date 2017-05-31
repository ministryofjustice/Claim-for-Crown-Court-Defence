module API
  module Entities
    class Document < BaseEntity
      expose :uuid, if: ->(instance, _opts) { instance.respond_to?(:uuid) }
      expose :url
      expose :file_name
      expose :size

      private

      def attachment
        object.is_a?(Paperclip::Attachment) ? object : object.attachment
      end

      def url
        attachment.url(nil, timestamp: false)
      end

      def file_name
        attachment.original_filename
      end

      def size
        attachment.size
      end
    end
  end
end
