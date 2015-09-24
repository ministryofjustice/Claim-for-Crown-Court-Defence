class JsonSchema

  class << self

    def generate(json_template)
      schema = JSON::SchemaGenerator.generate 'Advocate Defense Payments - Claim Import', json_template
      parsed_schema = JSON.parse(schema)
      edit_required_items(parsed_schema) # aside from checking for case_number presence, schema is only used to validate data type and json structure
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
      non_required_items = ['advocate_email', 'additional_information', "trial_fixed_notice_at", "trial_fixed_at", "trial_cracked_at", "trial_cracked_at_third", "case_type_id", "indictment_number", "first_day_of_trial", "estimated_trial_length", "actual_trial_length", "trial_concluded_at", "advocate_category", "offence_id", "court_id", "cms_number", "apply_vat", "defendants", "fees", "expenses"]
      non_required_items.each do |item|
        parsed_schema['properties']['claim']['required'].delete(item)
      end
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
      parsed_schema['properties']['claim']['properties']['expenses']['items']['properties']['dates_attended']['items'].delete('required')
    end

  end
end