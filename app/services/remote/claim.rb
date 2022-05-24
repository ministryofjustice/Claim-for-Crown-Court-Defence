module Remote
  class Claim < Base
    attr_accessor :case_number,
                  :state,
                  :type,
                  :last_submitted_at,
                  :total,
                  :vat_amount,
                  :opened_for_redetermination,
                  :written_reasons_outstanding,
                  :messages_count,
                  :unread_messages_count,
                  :disk_evidence,
                  :prosecution_evidence

    has_one :external_user
    has_one :case_type
    has_many :defendants
    has_many :case_workers
    has_one :court
    has_many :injection_attempts

    alias opened_for_redetermination? opened_for_redetermination
    alias written_reasons_outstanding? written_reasons_outstanding

    class << self
      def resource_path
        'case_workers/claims'
      end

      def user_allocations(user, **query)
        all_by_status('current', user:, query:)
      end

      def allocated(user, **query)
        all_by_status('allocated', user:, query:)
      end

      def unallocated(user, **query)
        all_by_status('unallocated', user:, query:)
      end

      def archived(user, **query)
        all_by_status('archived', user:, query:)
      end

      private

      def all_by_status(status, user:, query:)
        all(api_key: user.api_key, status:, **query)
      end
    end

    def total_including_vat
      total + vat_amount
    end

    def presenter
      [type, 'Presenter'].join.constantize
    end
  end
end
