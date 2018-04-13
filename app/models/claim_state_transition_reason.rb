class ClaimStateTransitionReason
  class ReasonNotFoundError < StandardError; end
  class StateNotFoundError < StandardError; end

  attr_accessor :code, :description, :long_description

  TRANSITION_REASONS = {
    rejected: {
      no_indictment: {
        short: 'No indictment attached',
        long: 'We rejected your claim because you didn’t attach the indictment. Please submit the claim again with the indictment. You can download a copy from the Digital Case System.'
      },
      no_rep_order: {
        short: 'No Magistrates’ representation order attached (granted before 1/8/2015)',
        long: 'We rejected your claim because you didn’t attach the representation order. Please submit the claim again with the representation order. You can get a copy from the Magistrates’ Court where it was issued.'
      },
      time_elapsed: {
        short: 'Claim significantly out of time with no explanation.',
        long: 'We rejected your claim because the case ended over 3 months ago. Please submit the claim again explaining why it is late.'
      },
      no_amend_rep_order: {
        short: 'No amending representation order',
        long: 'We rejected your claim because you didn’t attach the amending representation order – both the original and the amended order confirming a change in representation. Please submit the claim again with both representation orders.'
      },
      case_still_live: {
        short: 'Case still live',
        long: 'We rejected your claim because our records show the case hasn’t ended. Please submit the claim again when the case has ended, including any hearings for sentencing.'
      },
      wrong_case_no: {
        short: 'Incorrect case number',
        long: 'We rejected your claim because the case number didn’t match court records for this defendant. Please check the case details and submit the claim again.'
      },
      wrong_maat_ref: {
        short: 'Wrong MAAT reference',
        long: 'We rejected your claim because the MAAT reference you provided does not match the defendant records. Please check the MAAT reference number for this defendant and submit the claim again.'
      },
      other: {
        short: 'Other',
        long: 'Other'
      }
    },
    disbursement: {
      no_prior_authority: {
        short: 'No prior authority provided',
        long: 'We rejected your claim because you didn’t attach the authorised prior authority for the interim disbursement. Please submit the claim again with a copy of the document. '
      },
      no_invoice: {
        short: 'No invoice provided',
        long: 'We rejected your claim because you didn’t attach the final invoice. Please submit the claim again with the final invoice clearly stating the breakdown of costs and defendant’s name. We cannot accept estimated costs.'
      }
    },
    refused_advocate_claims: {
      wrong_ia: {
        short: 'Wrong Instructed Advocate',
        long: 'We rejected your claim because court records show a different advocate was instructed for the case. Please submit the claim again with the correct advocate details or include evidence to support why you think the court records are wrong.'
      },
      duplicate_claim: {
        short: 'Duplicate claim',
        long: ''
      },
      other_refuse: {
        short: 'Other',
        long: ''
      }
    },
    refused_litigator_claims: {
      duplicate_claim: {
        short: 'Duplicate claim',
        long: 'We refused your claim because our records show this bill has already been paid.'
      },
      other_refuse: {
        short: 'Other',
        long: ''
      }
    },
    refused_transfer_claims: {
      duplicate_claim: {
        short: 'Duplicate claim',
        long: 'We refused your claim because our records show this bill has already been paid.'
      },
      other_refuse: {
        short: 'Other',
        long: ''
      }
    },
    refused_interim_claims: {
      duplicate_claim: {
        short: 'Duplicate claim',
        long: 'We refused your claim because our records show this bill has already been paid.'
      },
      no_effective_pcmh: {
        short: 'No effective PCMH has taken place',
        long: ''
      },
      no_effective_trial: {
        short: 'No effective trial start has taken place',
        long: ''
      },
      short_trial: {
        short: 'The trial estimate was less than 10 days',
        long: ''
      },
      other_refuse: {
        short: 'Other',
        long: ''
      }
    },
    global: {
      timed_transition:{
        short:'TimedTransition::Transitioner',
        long: 'TimedTransition::Transitioner'
      }
    }
  }.with_indifferent_access.freeze

  def initialize(code, description, long_description = nil)
    self.code = code
    self.description = description
    self.long_description = long_description
  end

  def ==(other)
    (code == other.code) && (description == other.description)
  end

  class << self
    def get(code)
      new(code, description_for(code), description_for(code, :long)) unless code.blank?
    end

    def reasons(state)
      reasons_for(state)
    end

    def reject_reasons_for(claim)
      reasons = reasons_for('rejected')
      reasons.insert(6, reasons_for(:disbursement)) if claim&.fees&.first&.fee_type&.code.eql?('IDISO')
      reasons.flatten
    end

    def refuse_reasons_for(claim)
      reasons_for("refused_#{claim.class.to_s.demodulize.tableize}")
    end

    private

    def description_for(code, description_type = :short)
      reasons_map.values.reduce({}, :merge).fetch(code).fetch(description_type)
    rescue KeyError
      raise ReasonNotFoundError, "Reason with code '#{code}' not found"
    end

    def reasons_for(state)
      reasons_map.fetch(state).map { |code, descriptions| new(code, descriptions.fetch(:short), descriptions.fetch(:long)) }
    rescue KeyError
      raise StateNotFoundError, "State with name '#{state}' not found"
    end

    def reasons_map
      TRANSITION_REASONS
    end
  end
end
