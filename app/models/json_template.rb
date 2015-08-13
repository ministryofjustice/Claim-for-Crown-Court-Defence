class JsonTemplate

  class << self 

    def generate
      set_models_hash
      insert_values_for_typing
      arrays_where_appropriate
      format_keys
      JSON.pretty_generate(@models_hash)
    end

    private

    def constants
      api_constants = API::V1::Advocates.constants
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
      constant.to_s.constantize.superclass == ActiveRecord::Base
    end

    def set_models_hash
      @models_hash = {}
      models.each do |model|
        @models_hash[model] = get_route_params(model)
      end
    end

    def insert_values_for_typing
      get_klass_and_attributes_hash 
    end

    def get_klass_and_attributes_hash
      @models_hash.each do |model, attributes_hash| # iterate through @models_hash
        klass = model.to_s.constantize # generate class reference
        get_attribute_names(klass, attributes_hash)
      end
    end

    def get_attribute_names(klass, attributes_hash)
      attributes_hash.keys.each do |attribute_name| # iterate through attributes_hash
        set_data_type(klass, attribute_name, attributes_hash)
      end
    end

    def set_data_type(klass, attribute_name, attributes_hash)
      if klass.columns_hash[attribute_name] != nil # if the class this attribute
        use_data_type_from_model(klass, attribute_name, attributes_hash)
      elsif attribute_name =~ /email/ # to account for email attribute which is on Defendant, not claim
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

    def arrays_where_appropriate
      @models_hash.each do |model_key, atts_value|
        if another_model_has_many?(model_key) == true
          @models_hash[model_key] = [atts_value]
        end
      end
    end

    def format_keys
      snake_case_keys
      downcase_keys
      pluralize_keys_pointing_to_arrays
    end

    def downcase_keys
      @models_hash.keys.each do |key|
        @models_hash[key.downcase] = @models_hash.delete(key)
      end
    end

    def snake_case_keys
      @models_hash.keys.each do |key|
        @models_hash[key.to_s.underscore] = @models_hash.delete(key)
      end
    end

    def pluralize_keys_pointing_to_arrays
      @models_hash.keys.each do |key|
        @models_hash[key.pluralize] = @models_hash.delete(key) if @models_hash[key].class == Array
      end
    end

    def another_model_has_many?(model_key)
      associate = model_key.to_s.underscore.pluralize.to_sym
      models.each do |model|
        klass = model.to_s.constantize
        if klass.reflect_on_association(associate) != nil && klass.reflect_on_association(associate).macro == :has_many
          return true
        end
      end
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
      }
    end

    def get_route_params(const)
      API::V1::Advocates.const_get(const).endpoints.first.routes.first.route_params
    end
    
  end

end