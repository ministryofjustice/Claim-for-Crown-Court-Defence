class ClaimTextfieldValidator < BaseClaimValidator

  @@claim_textfield_validator_fields = [
    :case_type,
    :court,
    :case_number,
    :advocate_category,
    :offence
  ]

  private

  # ALWAYS required/mandatory (even for draft claims)
  def validate_advocate
    # TODO validates :advocate,                presence: true
  end

  # ALWAYS required/mandatory
  def validate_creator
    validate_presence(:creator, "Creator cannot be blank, a creator of the claim must be provided - this error indicates a problem")
  end

  # required/mandatory
  def validate_case_type
    validate_presence(:case_type, "Case type cannot be blank, you must select a case type")
  end

  # required/mandatory
  def validate_court
    validate_presence(:court, "Court cannot be blank, you must select a court")
  end

  # required/mandatory
  # format must a letter followed by 8 digits
  def validate_case_number
    validate_presence(:case_number, "Case number cannot be blank, you must enter a case number")
    validate_pattern(:case_number, /^[A-Z]{1}\d{8}$/, "Case number must be in format A12345678 (i.e. 1 capital Letter followed by exactly 8 digits)")
  end

# required/mandatory
# must be one of values in list
def validate_advocate_category
#   # validates :advocate_category,       presence: true,     inclusion: { in: Settings.advocate_categories }, if: :perform_validation?
  validate_presence(:advocate_category, "Advocate category cannot be blank, you must select an appropriate advocate category")
  validate_inclusion(:advocate_category, Settings.advocate_categories, "Advocate category must be one of those in the provided list")
end

# required/mandatory unless case type is breach of crown court order
def validate_offence
  validate_presence(:offence, "Offence Category cannot be blank, you must select an offence category") unless case_type_in("Breach of Crown Court order")
end


# # required/mandatory
# TODO def validate_estimated_trial_length
#   # validates :estimated_trial_length,  numericality: { greater_than_or_equal_to: 0 }, if: :perform_validation?
# end

# TODO def validate_actual_trial_length
#   # validates :actual_trial_length,     numericality: { greater_than_or_equal_to: 0 }, if: :perform_validation?
# end

  # TODO superclass methods
  # -------------------------
  def validate_pattern(attribute, pattern, message)
    return if @record.__send__(attribute).nil?
    add_error(attribute, message) unless @record.__send__(attribute).match(pattern)
  end

  def validate_inclusion(attribute, inclusion_list, message)
    return if @record.__send__(attribute).nil?
    add_error(attribute, message) unless inclusion_list.include?(@record.__send__(attribute))
  end

end