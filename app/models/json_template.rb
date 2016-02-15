class JsonTemplate

  class << self

    def generate
      set_models_hash
      remove_ids_of_non_existent_items
      insert_values_for_typing
      nested_arrays_where_appropriate
      clean_up
      format_keys
      @models_hash.to_json
    end

    private

    def constants
      api_constants = API::V1::ExternalUsers.constants
      [:Root, :ErrorResponse].each {|non_model_constant| api_constants.delete(non_model_constant) }
      api_constants
    end

    def models
      models = []
      constants.each do |constant|
        models << constant if refers_to_model?(constant)
      end
      return models
    end

    def refers_to_model?(constant)
      return true if constant == :Claim
      constant.to_s.constantize <= ActiveRecord::Base
    end

    def set_models_hash
      @models_hash = {}
      models.each do |model|
        model_key = model == :Claim ? :'Claim::BaseClaim' : model
        @models_hash[model_key] = get_route_params(model)
      end
    end

    def remove_ids_of_non_existent_items # items that will be created by importing the template
      @models_hash[:Defendant].delete('claim_id')
      @models_hash[:RepresentationOrder].delete('defendant_id')
      @models_hash[:Fee].delete('claim_id')
      @models_hash[:Expense].delete('claim_id')
      @models_hash[:DateAttended].delete('attended_item_id')
    end

    def insert_values_for_typing
      get_klass_and_attributes_hash
    end

    def get_klass_and_attributes_hash
      @models_hash.each do |model, attributes_hash| # iterate through @models_hash
        klass = class_from_symbol(model)
        get_attribute_names(klass, attributes_hash)
      end
    end

    def get_attribute_names(klass, attributes_hash)
      attributes_hash.keys.each do |attribute_name| # iterate through attributes_hash
        set_data_type(klass, attribute_name, attributes_hash)
      end
    end

    def set_data_type(klass, attribute_name, attributes_hash)
      if klass.columns_hash[attribute_name] # if the class has this attribute
        use_data_type_from_model(klass, attribute_name, attributes_hash)
      elsif ['api_key','creator_email','advocate_email'].include?(attribute_name) # handle non-model attributes of string type
        attributes_hash[attribute_name] = 'string' # and is of type 'string'
      end
    end

    def use_data_type_from_model(klass, attribute_name, attributes_hash)
      data_type = get_data_type(klass, attribute_name)
      attributes_hash[attribute_name] = data_type # set value in attributes_hash
    end

    def get_data_type(klass, attribute_name)
      active_record_data_type = klass.columns_hash[attribute_name].type
      types_hash[active_record_data_type]
    end

    def nested_arrays_where_appropriate
      @to_clean = []
      @models_hash.each do |model_key, atts_value|
        if another_model_has_many?(model_key) == true
          @owners.each do |owner|
            @models_hash[owner][model_key] = [atts_value]
            @to_clean << model_key
          end
        end
      end
    end

    def clean_up
      @to_clean.each do |model|
        @models_hash.delete(model)
      end
    end

    def format_keys
      snake_case_keys(@models_hash)
      downcase_keys(@models_hash)
      pluralize_keys_pointing_to_arrays(@models_hash)
    end

    def downcase_keys(hash)
      hash.keys.each do |key|
        hash[key.downcase] = hash.delete(key)
        downcase_keys(hash[key.downcase]) if hash[key.downcase].is_a? Hash
      end
    end

    def snake_case_keys(hash)
      hash.keys.each do |key|
        new_key = key.to_s.underscore
        value = hash.delete(key)
        hash[new_key] = value
        snake_case_keys(hash[new_key]) if hash[new_key].is_a? Hash
        snake_case_keys(hash[new_key].first) if hash[new_key].is_a? Array
      end
    end

    def pluralize_keys_pointing_to_arrays(hash)
      hash.keys.each do |key|
        if hash[key].is_a? Hash
          pluralize_keys_pointing_to_arrays(hash[key])
        elsif hash[key].is_a? Array
          hash[key.pluralize] = hash.delete(key)
          pluralize_keys_pointing_to_arrays(hash[key.pluralize].first)
        end
      end
    end

    def another_model_has_many?(model_key)
      associate = model_key.to_s.underscore.pluralize.to_sym
      @owners = []
      models.each do |model|
        klass = class_from_symbol(model)
        if klass.reflect_on_association(associate) != nil && klass.reflect_on_association(associate).macro == :has_many
          @owners << klass.to_s.to_sym
        end
      end
      return true unless @owners.blank?
    end

    def class_from_symbol(sym)
      sym == :Claim ? Claim::BaseClaim : sym.to_s.constantize
    end

    def types_hash
      {
        integer: 1,
        string: 'string',
        boolean: true,
        datetime: 'string',
        text: 'string',
        date: 'string',
        decimal: 1.1,
        float: 1.1
      }
    end

    def get_route_params(const)
      route_params = API::V1::ExternalUsers.const_get(const).endpoints.first.routes.first.route_params
      route_params.delete("api_key")
      route_params
    end

  end

end
