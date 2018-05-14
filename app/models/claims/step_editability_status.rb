module Claims
  class StepEditabilityStatus
    attr_reader :editable, :invalid_dependencies

    def initialize(editable, invalid_dependencies = [])
      @editable = editable
      @invalid_dependencies = invalid_dependencies || []
    end

    def valid?
      editable && invalid_dependencies.empty?
    end
  end
end
