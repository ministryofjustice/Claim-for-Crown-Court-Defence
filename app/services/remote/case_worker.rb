module Remote
  class CaseWorker < Remote::User

    class << self
      def resource_path
        'case_workers'
      end

      def all(user, query = {})
        super(query.merge(api_key: user.api_key))
      end
    end

  end
end
