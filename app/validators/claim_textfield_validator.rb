class ClaimTextfieldValidator < BaseClaimValidator

  def self.fields
    [
    :case_type,
    :court,
    :case_number,
    :advocate_category,
    :offence,
    :estimated_trial_length,
    :actual_trial_length,
    :trial_cracked_at_third,
    # :total
    ]
  end

  def self.mandatory_fields
    [
    :advocate,
    :creator,
    :amount_assessed,
    :evidence_checklist_ids
    ]
  end

  private

  #
  # TODO: removed as is causing odd behaviour due to the save
  #       if total needs to be validated it must be donein an after
  #       save hook or by an alternative means.
  #
  # def validate_total
    # if @record.persisted? && @record.source != 'api'
      # validate_numericality(:total, 0.01, nil, "The total being claimed for must be greater than £0.00")
    # else
      # curr_force_validation = @record.force_validation?
      # @record.force_validation = false # prevent this validation being called reursively
      # @record.save # trigger total update
      # validate_numericality(:total, 0.01, nil, "The total being claimed for must be greater than £0.00")
      # @record.force_validation = curr_force_validation # ensure the force validation returned to previous state
    # end
  # end

  # ALWAYS required/mandatory
  def validate_advocate
    validate_presence(:advocate, "Advocate cannot be blank, you must provide an advocate")
  end

  # ALWAYS required/mandatory
  def validate_creator
    validate_presence(:creator, "Creator cannot be blank, you must provide an creator")
  end

  # must be present
  def validate_case_type
    validate_presence(:case_type, "Case type cannot be blank, you must select a case type")
  end

  # must be present
  def validate_court
    validate_presence(:court, "Court cannot be blank, you must select a court")
  end

  # must be present
  # must have a format of capital letter followed by 8 digits
  def validate_case_number
    validate_presence(:case_number, "Case number cannot be blank, you must enter a case number")
    validate_pattern(:case_number, /^[A-Z]{1}\d{8}$/, "Case number must be in format A12345678") unless @record.case_number.blank?
  end

# must be present
# must be one of values in list
def validate_advocate_category
  validate_presence(:advocate_category, "Advocate category cannot be blank, you must select an appropriate advocate category")
  validate_inclusion(:advocate_category, Settings.advocate_categories, "Advocate category must be one of those in the provided list") unless @record.advocate_category.blank?
end

# must be present unless case type is breach of crown court order
def validate_offence
  validate_presence(:offence, "Offence Category cannot be blank, you must select an offence category") unless case_type_in("Breach of Crown Court order")
end

# must be present
# must be greater than or eqaul zero
def validate_estimated_trial_length
  validate_presence(:estimated_trial_length, "Estimated trial length cannot be blank, you must enter an estimated trial length") if trial_dates_required?
  validate_numericality(:estimated_trial_length, 0, nil, "Estimated trial length must be a whole number (0 or above)") unless @record.estimated_trial_length.nil?
end

# must be present
# must be greater than or equal to zero
def validate_actual_trial_length
  validate_presence(:actual_trial_length, "Actual trial length cannot be blank, you must enter an actual trial length") if trial_dates_required?
  validate_numericality(:actual_trial_length, 0, nil, "Actual trial length must be a whole number (0 or above)") unless @record.actual_trial_length.nil?
end


# must be present if case type is cracked trial or cracked before retial
# must be final third if case type is cracked before retrial (cannot be first or second third)
def validate_trial_cracked_at_third
  validate_presence(:trial_cracked_at_third,"Case cracked in cannot be blank for a #{@record.case_type.name}, please inidicate the third in which the case cracked") if cracked_case?
  validate_pattern(:trial_cracked_at_third, /^final_third$/, "Case cracked in can only be Final Third for trials that cracked before retrial") if (@record.case_type.name == 'Cracked before retrial' rescue false)
end

def validate_amount_assessed
  case @record.state
    when 'authorised', 'part_authorised'
      add_error(:amount_assessed, "Amount assessed cannot be zero for claims in state #{@record.state.humanize}") if @record.assessment.blank?
    when 'draft', 'refused', 'rejected', 'submitted'
      add_error(:amount_assessed, "Amount assessed must be zero for claims in state #{@record.state.humanize}") if @record.assessment.present?
  end
end

def validate_evidence_checklist_ids
  raise ActiveRecord::SerializationTypeMismatch.new("Attribute was supposed to be a Array, but was a #{@record.evidence_checklist_ids.class}.") unless @record.evidence_checklist_ids.is_a?(Array)

  # prevent non-numeric array elements
  # NOTE: non-numeric strings/chars will yield a value of 0 and this is checked for to add an error
  @record.evidence_checklist_ids = @record.evidence_checklist_ids.select(&:present?).map(&:to_i)
  if @record.evidence_checklist_ids.include?(0)
    add_error(:evidence_checklist_ids, "Evidence checklist ids are of an invalid type or zero, please use valid Evidence checklist ids")
    return
  end

  # prevent array elements that do no represent a doctype
  valid_doctype_ids = DocType.all.map(&:id)
  @record.evidence_checklist_ids.each do |id|
    unless valid_doctype_ids.include?(id)
      add_error(:evidence_checklist_ids, "Evidence checklist id #{id} is invalid, please use valid evidence checklist ids")
    end
  end

end


# local helpers
# ---------------------------
# def claim_total
#   byebug
#   @record.fees.map(&:amount).compact.sum + @record.expenses.map(&:amount).compact.sum
# end

def trial_dates_required?
  @record.case_type.requires_trial_dates rescue false
end

def cracked_case?
  @record.case_type.name.match(/[Cc]racked/) rescue false
end

def has_fees_or_expenses_attributes?
  (@record.fixed_fees.present? || @record.misc_fees.present?) || (@record.basic_fees.present? || @record.expenses.present?)
end

end
