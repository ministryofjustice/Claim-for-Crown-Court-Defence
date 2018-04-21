class ClaimStateTransitionReason
  class ReasonNotFoundError < StandardError; end
  class StateNotFoundError < StandardError; end

  attr_accessor :code, :description, :long_description

  def self.klass_scope
    [to_s.demodulize.underscore.downcase.to_sym]
  end

  def self.t(local_scope)
    I18n.t(local_scope, scope: klass_scope)
  end

  TRANSITION_REASON_KEYS = {
    rejected: {
      no_indictment: {
        short: '',
        long: ''
      },
      no_rep_order: {
        short: '',
        long: ''
      },
      time_elapsed: {
        short: '',
        long: ''
      },
      no_amend_rep_order: {
        short: '',
        long: ''
      },
      case_still_live: {
        short: '',
        long: ''
      },
      wrong_case_no: {
        short: '',
        long: ''
      },
      wrong_maat_ref: {
        short: '',
        long: ''
      },
      other: {
        short: '',
        long: ''
      }
    },
    disbursement: {
      no_prior_authority: {
        short: '',
        long: ''
      },
      no_invoice: {
        short: '',
        long: ''
      }
    },
    refused_advocate_claims: {
      wrong_ia: {
        short: '',
        long: ''
      },
      duplicate_claim: {
        short: '',
        long: ''
      },
      other_refuse: {
        short: '',
        long: ''
      }
    },
    refused_litigator_claims: {
      duplicate_claim: {
        short: '',
        long: ''
      },
      other_refuse: {
        short: '',
        long: ''
      }
    },
    refused_transfer_claims: {
      duplicate_claim: {
        short: '',
        long: ''
      },
      other_refuse: {
        short: '',
        long: ''
      }
    },
    refused_interim_claims: {
      duplicate_claim: {
        short: '',
        long: ''
      },
      no_effective_pcmh: {
        short: '',
        long: ''
      },
      no_effective_trial: {
        short: '',
        long: ''
      },
      short_trial: {
        short: '',
        long: ''
      },
      other_refuse: {
        short: '',
        long: ''
      }
    },
    global: {
      timed_transition: {
        short: '',
        long: ''
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
    def get(code, other_reason = nil)
      return if code.blank?
      return new(code, description_for(code), other_reason) if %w[other other_refuse].include?(code)
      new(code, description_for(code), description_for(code, :long))
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

    def transition_reasons
      return @transition_reasons unless @transition_reasons.nil?
      @transition_reasons ||= TRANSITION_REASON_KEYS.dup # unfreeze
      @transition_reasons.key_paths.each do |key_path|
        @transition_reasons.bury(t(key_path.join('.')), *key_path)
      end
      @transition_reasons
    end

    private

    def description_for(code, description_type = :short)
      transition_reasons.values.reduce({}, :merge).fetch(code).fetch(description_type)
    rescue KeyError
      raise ReasonNotFoundError, "Reason with code '#{code}' not found"
    end

    def reasons_for(state)
      transition_reasons.fetch(state).map do |code, descriptions|
        new(code, descriptions.fetch(:short), descriptions.fetch(:long))
      end
    rescue KeyError
      raise StateNotFoundError, "State with name '#{state}' not found"
    end
  end
end
