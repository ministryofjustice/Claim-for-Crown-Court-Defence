module CCR
  class AdvocateCategoryAdapter
    TRANSLATION_TABLE = {
      'QC': 'QC',
      'Led junior': 'LEDJR',
      'Leading junior': 'LEADJR',
      'Junior alone': 'JRALONE',
      'Junior': 'JUNIOR'
    }.stringify_keys.freeze

    class << self
      def code_for(category)
        TRANSLATION_TABLE.fetch(category)
      end
    end
  end
end
