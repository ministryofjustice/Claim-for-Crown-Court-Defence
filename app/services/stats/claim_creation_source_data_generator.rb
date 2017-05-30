module Stats
  class ClaimCreationSourceDataGenerator < BaseDataGenerator
    private

    def report_types
      {
        'creations_source_web'  => 'Web',
        'creations_source_api'  => 'API',
        'creations_source_json' => 'JSON'
      }
    end
  end
end
