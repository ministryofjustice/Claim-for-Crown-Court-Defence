module Remote
  class Claim < Base
    attr_accessor :uuid,
                  :case_number,
                  :state,
                  :type,
                  :last_submitted_at,
                  :total,
                  :vat_amount,
                  :opened_for_redetermination,
                  :written_reasons_outstanding,
                  :messages_count,
                  :unread_messages_count,
                  :external_user,
                  :defendants,
                  :case_type

    alias opened_for_redetermination? opened_for_redetermination
    alias written_reasons_outstanding? written_reasons_outstanding

    class << self
      def resource_path
        'case_workers/claims'
      end

      def allocated(user, query = {})
        all_by_status('allocated', user: user, query: query)
      end

      def archived(user, query = {})
        all_by_status('archived', user: user, query: query)
      end

      private

      def all_by_status(status, user:, query:)
        all(query.merge(api_key: user.api_key, status: status))
      end
    end

    def external_user=(attrs)
      @external_user = Remote::ExternalUser.new(attrs)
    end

    def defendants=(attrs)
      @defendants = attrs.map { |d| Remote::Defendant.new(d) }
    end

    def case_type=(attrs)
      @case_type = Remote::CaseType.new(attrs)
    end

    def total_including_vat
      total + vat_amount
    end

    def presenter
      [type, 'Presenter'].join.constantize
    end
  end
end
