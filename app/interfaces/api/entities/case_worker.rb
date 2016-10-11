module API
  module Entities
    class CaseWorker < API::Entities::User
      expose :email
    end
  end
end
