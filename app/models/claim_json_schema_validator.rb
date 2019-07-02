class ClaimJsonSchemaValidator
  CCR_SCHEMA_FILE = File.join(Rails.root, 'config', 'schemas', 'ccr_claim_schema.json').freeze
  CCLF_SCHEMA_FILE = File.join(Rails.root, 'config', 'schemas', 'cclf_claim_schema.json').freeze

  class << self
    def ccr_schema
      File.read(CCR_SCHEMA_FILE)
    end

    def cclf_schema
      File.read(CCLF_SCHEMA_FILE)
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
