class JsonSchema
  class << self
    def generate
      schema = File.read(File.join(Rails.root, 'config', 'claim_schema.json'))
      parsed_schema = JSON.parse(schema)
      edit_required_items(parsed_schema) # schema is used to validate data type and json structure only
      parsed_schema
    end

    def edit_required_items(parsed_schema)
      from_claim(parsed_schema)
      from_defendants(parsed_schema)
      from_representation_orders(parsed_schema)
      from_fees(parsed_schema)
      from_expenses(parsed_schema)
      from_dates_attended(parsed_schema)
    end

    def from_claim(parsed_schema)
      parsed_schema['properties']['claim'].delete('required')
    end

    def from_defendants(parsed_schema)
      parsed_schema['properties']['claim']['properties']['defendants']['items'].delete('required')
    end

    def from_representation_orders(parsed_schema)
      parsed_schema['properties']['claim']['properties']['defendants']['items']['properties']['representation_orders']['items'].delete('required')
    end

    def from_fees(parsed_schema)
      parsed_schema['properties']['claim']['properties']['fees']['items'].delete('required')
    end

    def from_expenses(parsed_schema)
      parsed_schema['properties']['claim']['properties']['expenses']['items'].delete('required')
    end

    def from_dates_attended(parsed_schema)
      parsed_schema['properties']['claim']['properties']['fees']['items']['properties']['dates_attended']['items'].delete('required')
    end
  end
end
