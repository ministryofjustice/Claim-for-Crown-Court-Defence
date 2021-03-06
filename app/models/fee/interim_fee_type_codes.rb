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
  end
end
