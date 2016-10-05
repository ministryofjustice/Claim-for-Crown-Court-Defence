module API
  module Entities
    class Claim < UndatedEntity
      expose :id
      expose :uuid
      expose :case_number
      expose :state
      expose :type
      expose :last_submitted_at, format_with: :utc
      expose :total, format_with: :decimal
      expose :vat_amount, format_with: :decimal
      expose :opened_for_redetermination?, as: :opened_for_redetermination
      expose :written_reasons_outstanding?, as: :written_reasons_outstanding

      expose :messages_count
      expose :unread_messages_count do |_instance, options|
        unread_messages_count(options[:user])
      end

      expose :external_user, using: API::Entities::ExternalUser
      expose :defendants, using: API::Entities::Defendant
      expose :case_type, using: API::Entities::CaseType

      private

      def messages_count
        object.messages.count
      end

      def unread_messages_count(user)
        object.unread_messages_for(user).count
      end
    end
  end
end
