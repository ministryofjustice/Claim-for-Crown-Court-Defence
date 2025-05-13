module Fee
  class MiscFeeType < Fee::BaseFeeType
    AGFS_SUPPLEMENTARY_ONLY_TYPES = %w[MISAF MIPCM].freeze
    AGFS_SUPPLEMENTARY_SHARED_TYPES = %w[MISAU MISPF MIWPF MIDTH MIDTW MIDHU MIDWU
                                         MIDSE MIDSU MIPHC MISHR MISHU MIUMU MIUMO MISTE MIAPF MIFCM].freeze
    AGFS_SUPPLEMENTARY_TYPES = (AGFS_SUPPLEMENTARY_ONLY_TYPES + AGFS_SUPPLEMENTARY_SHARED_TYPES).freeze
    TRIAL_ONLY_TYPES = %w[MIUMU MIUMO MISTE MIAPF].freeze

    default_scope { order(Arel.sql("regexp_replace(\"fee_types\".\"description\", '[()]', '', 'g')")) }

    scope :without_supplementary_only, -> { where.not(unique_code: AGFS_SUPPLEMENTARY_ONLY_TYPES) }
    scope :supplementary, -> { where(unique_code: AGFS_SUPPLEMENTARY_TYPES) }
    scope :without_trial_fee_only, -> { where.not(unique_code: TRIAL_ONLY_TYPES) }

    def fee_category_name
      'Miscellaneous Fees'
    end
  end
end
