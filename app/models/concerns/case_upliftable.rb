# Certain basic and fixed fee types (and one LGFS only miscellaneous fee)
# relate to additional cases and therefore require those additional
# case numbers to be supplied

# In addition, of those fixed fees that are case uplifts
# there is a relationship between the uplift and its "parent"
# fee that is important when it comes to consolidating data for
# injection into CCR.
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
      unique_code.in?(%w[BANOC FXNOC FXACU FXASU FXCBU FXCSU FXCDU FXENU MIUPL])
    end
  end
end
