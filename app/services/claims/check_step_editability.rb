module Claims
  class CheckStepEditability
    def self.call(claim, step)
      new(claim, step).call
    end

    def initialize(claim, step)
      @claim = claim
      @original_step = claim.form_step
      @step = step
    end

    def call
      step_object = full_submission_flow.find { |s| s == step }
      return status(false) unless claim.editable? && step_object
      return status(true) if step_object.dependencies.empty?
      status(true, invalid_dependencies(step_object))
    ensure
      claim.form_step = original_step
    end

    private

    attr_reader :claim, :original_step, :step

    delegate :full_submission_flow, to: :claim

    def invalid_dependencies(step_object)
      step_object.dependencies.each_with_object([]) do |dependency, memo|
        claim.form_step = dependency
        claim.force_validation = true
        memo << dependency unless claim.valid?
      end
    end

    def status(editable, invalid_dependencies = [])
      Claims::StepEditabilityStatus.new(editable, invalid_dependencies)
    end
  end
end
