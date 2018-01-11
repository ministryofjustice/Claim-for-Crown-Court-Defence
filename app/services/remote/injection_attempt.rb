#
#  id             :integer          not null, primary key
#  claim_id       :integer
#  succeeded      :boolean
#  created_at     :datetime
#  updated_at     :datetime
#  error_messages :json

module Remote
  class InjectionAttempt < Base
    attr_accessor :succeeded, :error_messages

    def failed?
      !succeeded
    end
  end
end
