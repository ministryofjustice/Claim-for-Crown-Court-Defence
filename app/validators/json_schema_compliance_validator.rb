class JsonSchemaComplianceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.each do |claim_hash|
      unless JSON::Validator.validate(record.schema, claim_hash)
        record.errors[attribute] = JSON::Validator.fully_validate(record.schema, claim_hash)
      end
    end
  end
end