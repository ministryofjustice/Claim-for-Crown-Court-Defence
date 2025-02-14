class ClaimStateTransitionReason
  class ReasonNotFoundError < StandardError; end
  class StateNotFoundError < StandardError; end

  attr_accessor :code, :description, :long_description

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
      reasons = reasons_for("rejected_#{claim.agfs? ? 'advocate' : 'litigator'}_claims")
      reasons.insert(6, reasons_for(:disbursement)) if disbursement_only?(claim)
      reasons.flatten
    end

    def refuse_reasons_for(claim)
      reasons = reasons_for("refused_#{claim.class.to_s.demodulize.tableize}")
      if claim.lgfs?
        reason_key = if claim.redetermination? || claim.awaiting_written_reasons?
                       :refused_litigator_redetermination_claims
                     else
                       :refused_litigator_new_claims
                     end
        reasons.insert(1, reasons_for(reason_key))
      end
      reasons.flatten
    end

    def transition_reasons
      return @transition_reasons unless @transition_reasons.nil?
      translations = YAML.load_file(translations_file, aliases: true)
      @transition_reasons = translations.dig(I18n.locale.to_s, 'claim_state_transition_reason').with_indifferent_access
      @transition_reasons
    end

    private

    def translations_file
      @translations_file ||=
        Rails.root.join('config', 'locales', "claim_state_transition_reason.#{I18n.locale}.yml")
    end

    def disbursement_only?(claim)
      claim&.fees&.first&.fee_type&.code.eql?('IDISO')
    end

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
