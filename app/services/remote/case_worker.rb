module Remote
  class CaseWorker < Remote::User
    class << self
      def resource_path
        'case_workers'
      end

      def all(user, **query)
        super(api_key: user.api_key, **query)
      end
    end
  end
end
