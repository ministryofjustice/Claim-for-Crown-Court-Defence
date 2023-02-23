module ManagementInformationReportable
  extend ActiveSupport::Concern

  class_methods do
    COMPLETED_STATES = %w[rejected refused authorised part_authorised].freeze
    SUBMITTED_STATES = %w[submitted redetermination awaiting_written_reasons].freeze
  end

  included do
    def scheme
      if claim.agfs?
        'AGFS'
      elsif claim.lgfs?
        'LGFS'
      else
        'Unknown'
      end
    end

    def organisation
      provider.name
    end

    def case_type_name
      case_type&.name
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

    def claim_total
      format('%.2f', total_including_vat.round(4))
    end

    def submission_type
      @journey.first.to == 'submitted' ? 'new' : @journey.first.to
    end

    def transitioned_at
      submission_steps = @journey.select { |step| SUBMITTED_STATES.include?(step.to) }
      submission_steps.present? ? submission_steps.first.created_at.strftime('%d/%m/%Y') : 'n/a'
    end

    def last_submitted_at
      claim.last_submitted_at.strftime('%d/%m/%Y')
    end

    def originally_submitted_at
      original_submission_date.strftime('%d/%m/%Y')
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
      reason_code.presence
    end

    def rejection_reason
      @journey.last.reason_text
    end

    def case_worker
      return @journey.last.subject&.name if @journey.last.to == 'allocated'

      COMPLETED_STATES.include?(@journey.last.to) ? @journey.last.author&.name : 'n/a'
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

    def af1_lf1_processed_by
      previous_redetermination_steps.present? ? previous_redetermination_steps.last.author_name : nil
    end

    def misc_fees
      misc_fees = claim.misc_fees.map { |f| f.fee_type.description.tr(',', '') }.join(' ')
      misc_fees.presence
    end

    def main_hearing_date
      claim.main_hearing_date&.strftime('%d/%m/%Y')
    end

    def redetermination_steps
      @journey.select { |step| step.to == 'redetermination' }
    end
    private :redetermination_steps

    def previous_redetermination_steps
      redetermination_steps.present? ? previous(redetermination_steps.last) : nil
    end
    private :previous_redetermination_steps
  end
end
