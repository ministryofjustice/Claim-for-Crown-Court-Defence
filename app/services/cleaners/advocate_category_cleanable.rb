module Cleaners
  module AdvocateCategoryCleanable
    private

    def fix_advocate_categories
      return if fee_scheme.nil?

      @claim.advocate_category = 'KC' if fee_scheme.version >= 15 && @claim.advocate_category == 'QC'
      @claim.advocate_category = 'QC' if fee_scheme.version < 15 && @claim.advocate_category == 'KC'
    end
  end
end
