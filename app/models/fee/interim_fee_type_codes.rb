module Fee
  module InterimFeeTypeCodes
    TRIAL_APPLICABLE = %w[INPCM INTDT].freeze
    RETRIAL_APPLICABLE = %w[INRST INRNS].freeze

    def is_disbursement?
      code == 'IDISO'
    end

    def is_interim_warrant?
      code == 'IWARR'
    end

    def is_effective_pcmh?
      code == 'IPCMH'
    end

    def is_trial_start?
      code == 'ITST'
    end

    def is_retrial_start?
      code == 'IRST'
    end

    def is_retrial_new_solicitor?
      code == 'IRNS'
    end

    # TODO: remove unless need to use
    # def is_trial_applicable?
    #   !unique_code.in? self.class::RETRIAL_APPLICABLE
    # end

    # def is_retrial_applicable?
    #   !unique_code.in? self.class::TRIAL_APPLICABLE
    # end
  end
end
