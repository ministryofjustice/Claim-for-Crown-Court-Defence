module Cleaners
  class AdvocateInterimClaimCleaner < BaseClaimCleaner
    include AdvocateCategoryCleanable

    def call
      fix_advocate_categories
    end
  end
end
