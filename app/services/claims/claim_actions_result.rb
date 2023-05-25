module Claims
  class ClaimActionsResult
    attr_accessor :service, :success, :error_code
    delegate :action, :draft?, to: :service

    def initialize(service, error_code: nil)
      @service = service
      @success = error_code.nil?
      @error_code = error_code
    end

    def success?
      success
    end
  end
end
