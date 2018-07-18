# Extends fee type, adding a mapping of certain fixed
# fees to their case uplift equivalent - which is
# important for consolidating records for injection
# into CCR.
#
# In addition, specific basic and fixed fee types that
# require additional cases are flagged here for use in
# validation and presentation layers.
#
module CaseUpliftable
  extend ActiveSupport::Concern

  class_methods do
    CASE_UPLIFT_MAPPINGS = {
      FXACV: 'FXACU',
      FXASE: 'FXASU',
      FXCBR: 'FXCBU',
      FXCSE: 'FXCSU',
      FXENP: 'FXENU',
      FXCCD: 'FXCDU'
    }.with_indifferent_access.freeze

    ORPHAN_CASE_UPLIFTS = %w[BANOC FXNOC].freeze

    def case_uplifts
      where(unique_code: case_uplift_unique_codes)
    end

    def case_uplift_unique_codes
      CASE_UPLIFT_MAPPINGS.values + ORPHAN_CASE_UPLIFTS
    end
  end

  included do
    def case_uplift?
      unique_code.in?(self.class.case_uplift_unique_codes)
    end
  end
end
