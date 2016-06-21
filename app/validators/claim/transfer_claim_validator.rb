class Claim::TransferClaimValidator < Claim::BaseClaimValidator
  include Claim::LitigatorCommonValidations

  def self.fields_for_steps
    [
      [].unshift(first_step_common_validations),
      [
        :litigator_type,
        :elected_case,
        :transfer_stage_id,
        :transfer_date,
        :case_conclusion_id,
        :transfer_detail_combo,
        :total
      ]
    ]
  end

  private

  def validate_transfer_fee
    add_error(:transfer_fee, 'blank') if @record.transfer_fee.nil?
  end

  def validate_litigator_type
    unless @record.litigator_type.in? %w{ new original }
      add_error(:litigator_type, 'invalid')
    end
  end

  def validate_elected_case
    unless @record.elected_case.in?([true, false])
      add_error(:elected_case, 'invalid')
    end
  end

  def validate_transfer_stage_id
    unless @record.transfer_stage_id.in? Claim::TransferBrain.transfer_stage_ids
      add_error(:transfer_stage_id, 'invalid')
    end
  end

  def validate_transfer_date
    validate_presence(:transfer_date, 'blank')
    validate_not_after(Date.today, :transfer_date, 'check_not_in_future')
    validate_not_before(Settings.earliest_permitted_date, :transfer_date, 'check_not_too_far_in_past')
  end

  def validate_case_conclusion_id
    if Claim::TransferBrain.case_conclusion_required?(@record.transfer_detail)
      validate_presence(:case_conclusion_id, 'blank')
      validate_inclusion(:case_conclusion_id, Claim::TransferBrain.case_conclusion_ids, 'invalid')
    else
      validate_absence(:case_conclusion_id, 'present')
    end
  end

  def validate_transfer_detail_combo
    unless Claim::TransferBrain.details_combo_valid?(@record.transfer_detail)
      add_error(:transfer_detail, 'invalid_combo') # section error
      add_error(:case_conclusion_id, 'invalid_combo') # field helpful error
    end
  end
end
