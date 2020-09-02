class ClaimCsvPresenter < BasePresenter
  presents :claim

  include ClaimCSVHelpers

  def present!
    yield parsed_journeys if block_given?
  end

  def case_worker
    if claim.allocated?
      claim.case_workers.first.name
    else
      transition = claim.last_decision_transition
      transition&.author_name
    end
  end

  def claim_state
    if state == 'archived_pending_delete'
      claim_state_transitions.sort.last.from
    else
      state
    end
  end

  def organisation
    provider.name
  end

  def case_type_name
    case_type&.name || ''
  end

  def scheme
    if claim.agfs?
      'AGFS'
    elsif claim.lgfs?
      'LGFS'
    else
      'Unknown'
    end
  end

  def bill_type
    [
      scheme,
      type.demodulize
          .sub('Claim', '')
          .gsub(/([A-Z])/, ' \1')
          .gsub(/(Advocate |Litigator )/, '')
          .gsub(/(Advocate|Litigator)$/, 'Final')
          .strip
    ].join(' ')
  end

  def disk_evidence_case
    disk_evidence ? 'Yes' : 'No'
  end

  def main_defendant
    defendants&.first&.name
  end

  def maat_reference
    earliest_representation_order&.maat_reference
  end

  def rep_order_issued_date
    earliest_representation_order&.representation_order_date&.strftime('%d/%m/%Y')
  end

  def claim_total
    total_including_vat.to_s
  end

  def submission_type
    @journey.first.to == 'submitted' ? 'new' : @journey.first.to
  end

  def submitted_at
    submission_steps = @journey.select { |step| SUBMITTED_STATES.include?(step.to) }
    submission_steps.present? ? submission_steps.first.created_at.strftime('%d/%m/%Y') : 'n/a'
  end

  def allocated_at
    allocation_steps = @journey.select { |step| step.to == 'allocated' }
    allocation_steps.present? ? allocation_steps.last.created_at.strftime('%d/%m/%Y') : 'n/a'
  end

  def completed_at
    completion_steps = @journey.select { |step| COMPLETED_STATES.include?(step.to) }
    completion_steps.present? ? completion_steps.first.created_at.strftime('%d/%m/%Y %H:%M') : 'n/a'
  end

  def current_or_end_state
    state = @journey.last.to
    SUBMITTED_STATES.include?(state) ? 'submitted' : state
  end

  def state_reason_code
    reason_code = @journey.last.reason_code
    reason_code = reason_code.flatten.join(', ') if reason_code.is_a?(Array)
    reason_code
  end

  def rejection_reason
    @journey.last.reason_text
  end

  def previous(next_step)
    complete_journeys = sorted_and_filtered_state_transitions
    complete_journeys.select { |step| step.to == next_step.from && step.created_at < next_step.created_at }
  end

  def af1_lf1_processed_by
    redetermination_steps = @journey.select { |step| step.to == 'redetermination' }
    previous_steps = redetermination_steps.present? ? previous(redetermination_steps.last) : nil
    previous_steps.present? ? previous_steps.last.author_name : ''
  end

  def misc_fees
    claim.misc_fees.map { |f| f.fee_type.description.tr(',', '') }.join(' ')
  end
end
