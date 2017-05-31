class ClaimJsonSchemaValidator
  FULL_SCHEMA_FILE = File.join(Rails.root, 'config', 'schemas', 'full_claim_schema.json').freeze
  BASIC_SCHEMA_FILE = File.join(Rails.root, 'config', 'schemas', 'basic_claim_schema.json').freeze

  class << self
    def full_schema
      File.read(FULL_SCHEMA_FILE)
    end

    def basic_schema
      File.read(BASIC_SCHEMA_FILE)
    end

    def validate_full!(data)
      JSON::Validator.validate!(full_schema, data)
    end

    # Only checks for the object 'claim' in the JSON. Used to fail early in the JSON importer.
    # It can validate single objects {} or collections [{}, {}] in the JSON.
    #
    def validate_basic!(data)
      JSON::Validator.validate!(basic_schema, data, list: data.is_a?(Array))
    end
  end
end
