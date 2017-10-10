module API
  class ApiResponse
    attr_accessor :status, :body

    def success?(status_code = nil)
      code = status_code || '2'
      status.to_s.match?(/^#{code}/) ? true : false
    end
  end
end
