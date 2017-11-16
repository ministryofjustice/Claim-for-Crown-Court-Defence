class Claim::LitigatorSupplierNumberValidator < Claim::BaseClaimValidator
  include Claim::LitigatorSupplierNumberValidations

  def self.fields_for_steps
    {
      case_details: first_step_common_validations,
    }.with_indifferent_access
  end

  private

  delegate :current_step, to: :@record

  # TODO: overide base claim validator method for now
  # but this needs to be promoted eventually
  def validate_step_fields
    self.class.fields_for_steps[current_step]&.flatten&.each do |field|
      validate_field(field)
    end
  end
end
