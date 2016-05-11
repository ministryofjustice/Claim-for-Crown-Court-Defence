module Claims
  class ClaimActionsResult

    attr_accessor :success, :error_code

    def initialize(success: true, error_code: nil)
      self.success = success
      self.error_code = error_code
    end

    def success?
      success
    end

  end
end
