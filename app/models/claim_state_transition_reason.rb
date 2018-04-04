class ClaimStateTransitionReason
  class ReasonNotFoundError < StandardError; end
  class StateNotFoundError < StandardError; end

  attr_accessor :code, :description

  TRANSITION_REASONS = {
    rejected: {
      no_indictment: 'No indictment attached',
      no_rep_order: 'No Magistrates’ representation order attached (granted before 1/8/2015)',
      time_elapsed: 'Claim significantly out of time with no explanation.',
      no_amend_rep_order: 'No amending representation order',
      case_still_live: 'Case still live',
      wrong_case_no: 'Incorrect case number',
      wrong_maat_ref: 'Wrong MAAT reference',
      other: 'Other'
    },
    disbursement: {
      no_prior_authority: 'No prior authority provided',
      no_invoice: 'No invoice provided'
    },
    refused_advocate_claims: {
      wrong_ia: 'Wrong Instructed Advocate',
      duplicate_claim: 'Duplicate claim',
      other_refuse: 'Other'
    },
    refused_litigator_claims: {
      duplicate_claim: 'Duplicate claim',
      other_refuse: 'Other'
    },
    refused_transfer_claims: {
      duplicate_claim: 'Duplicate claim',
      other_refuse: 'Other'
    },
    refused_interim_claims: {
      duplicate_claim: 'Duplicate claim',
      no_effective_pcmh: 'No effective PCMH has taken place',
      no_effective_trial: 'No effective trial start has taken place',
      short_trial: 'The trial estimate was less than 10 days',
      other_refuse: 'Other'
    },
    global: {
      timed_transition: 'TimedTransition::Transitioner'
    }
  }.with_indifferent_access.freeze

  def initialize(code, description)
    self.code = code
    self.description = description
  end

  def ==(other)
    (code == other.code) && (description == other.description)
  end

  class << self
    def get(code)
      new(code, description_for(code)) unless code.blank?
    end

    def reasons(state)
      reasons_for(state)
    end

    def reject_reasons_for(claim)
      reasons = reasons_for('rejected')
      reasons.insert(6, reasons_for(:disbursement)) if claim.fees.first.fee_type.code.eql?('IDISO')
      reasons.flatten
    end

    def refuse_reasons_for(claim)
      reasons_for("refused_#{claim.class.to_s.demodulize.tableize}")
    end

    private

    def description_for(code)
      reasons_map.values.reduce({}, :merge).fetch(code)
    rescue KeyError
      raise ReasonNotFoundError, "Reason with code '#{code}' not found"
    end

    def reasons_for(state)
      reasons_map.fetch(state).map { |code, desc| new(code, desc) }
    rescue KeyError
      raise StateNotFoundError, "State with name '#{state}' not found"
    end

    def reasons_map
      TRANSITION_REASONS
    end
  end
end
