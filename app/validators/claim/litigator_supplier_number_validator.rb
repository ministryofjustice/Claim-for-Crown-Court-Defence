class Claim::LitigatorSupplierNumberValidator < Claim::BaseClaimValidator
  include Claim::LitigatorSupplierNumberValidations

  def self.fields_for_steps
    {
      case_details: first_step_common_validations
    }
  end

  private

  def step_fields_for_validation
    return super if @record.interim?
    self.class.fields_for_steps.select do |k, _v|
      @record.submission_current_flow.map(&:to_sym).include?(k)
    end.values.flatten
  end
end
