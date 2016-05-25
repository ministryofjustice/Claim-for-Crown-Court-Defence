module Claims
  class ClaimActionsResult

    attr_accessor :service, :success, :error_code
    delegate :action, :draft?, to: :service

    def initialize(service, success: true, error_code: nil)
      self.service = service
      self.success = success
      self.error_code = error_code
    end

    def success?
      success
    end

  end
end
