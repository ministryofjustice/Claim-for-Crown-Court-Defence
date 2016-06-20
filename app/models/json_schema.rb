class JsonSchema

  CLAIM_SCHEMA_FILE = File.join(Rails.root, 'config', 'claim_schema.json').freeze

  def self.claim_schema
    File.read(CLAIM_SCHEMA_FILE)
  end

end