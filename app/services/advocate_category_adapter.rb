class AdvocateCategoryAdapter

  TRANSLATION_TABLE = {
    'QC': 'QC',
    'Led junior': 'LEDJR',
    'Leading junior': 'LEADJR',
    'Junior alone': 'JRALONE'
  }.stringify_keys.freeze

  class << self
    def code_for(category)
      TRANSLATION_TABLE.fetch(category)
    end
  end
end
