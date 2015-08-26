class JsonSchema

  class << self

    def generate(json_template)
      schema = JSON::SchemaGenerator.generate 'Advocate Defense Payments - Claim Import', json_template
      parsed_schema = JSON.parse(schema)
      remove_non_required_items(parsed_schema)
      parsed_schema
    end

    def remove_non_required_items(parsed_schema)
      from_claim(parsed_schema)
      from_fees(parsed_schema)
      from_expenses(parsed_schema)
    end

    def from_claim(parsed_schema)
      non_required_items = ['additional_information', "trial_fixed_notice_at", "trial_fixed_at", "trial_cracked_at", "trial_cracked_at_third"]
      non_required_items.each do |item|
        parsed_schema['properties']['claim']['required'].delete(item)
      end
    end

    def from_fees(parsed_schema)
      parsed_schema['properties']['claim']['properties']['fees']['items']['required'].delete('dates_attended')
    end

    def from_expenses(parsed_schema)
      parsed_schema['properties']['claim']['properties']['expenses']['items']['required'].delete('dates_attended')
    end
  end
end