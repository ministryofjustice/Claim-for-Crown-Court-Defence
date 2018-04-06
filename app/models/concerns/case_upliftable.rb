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
      FXENP: 'FXENU'
    }.with_indifferent_access.freeze
  end

  included do
    def case_uplift?
      unique_code.in?(%w[BANOC FXNOC FXACU FXASU FXCBU FXCSU FXCDU FXENU])
    end
  end
end
