module API
  module Entities
    class Message < BaseEntity
      expose :created_at, format_with: :utc
      expose :sender_uuid
      expose :body
      expose  :attachments,
              as: :document,
              using: API::Entities::Document,
              if: ->(instance, _opts) { instance.attachments.present? }

      private

      def sender_uuid
        object.sender.persona.uuid
      end
    end
  end
end
