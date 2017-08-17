module CCR
  class AdvocateCategoryAdapter
    class << self
      def code_for(category)
        TRANSLATION_TABLE.fetch(category)
      end
    end

    private

    TRANSLATION_TABLE = {
      'QC': 'QC',
      'Led junior': 'LEDJR',
      'Leading junior': 'LEADJR',
      'Junior alone': 'JRALONE'
    }.stringify_keys.freeze
  end
end
