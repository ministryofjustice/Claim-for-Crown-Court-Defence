module MultiparameterAttributeCleanable
  extend ActiveSupport::Concern

  included do
    def clean_multiparameter_dates(new_attributes, attribute_names)
      return unless new_attributes

      attribute_names.map(&:to_s).each do |attribute_name|
        parse_and_clean_date_attributes(new_attributes, attribute_name)
      end
    end

    # TODO: ??? could extend to add errors to the model object
    # possible example: https://github.com/errriclee/validates_multiparameter_assignments/blob/master/lib/validates_multiparameter_assignments.rb
    #
    def parse_and_clean_date_attributes(new_attributes, attribute_name)
      date_parts = date_parts(new_attributes, attribute_name)
      return if date_parts.all?(&:blank?)

      Time.zone.local(*date_parts.map(&:to_i))
    rescue ArgumentError
      new_attributes["#{attribute_name}(2i)"] = '' unless (1..12).cover?(new_attributes["#{attribute_name}(2i)"].to_i)
      new_attributes["#{attribute_name}(3i)"] = '' unless (1..31).cover?(new_attributes["#{attribute_name}(3i)"].to_i)
    end

    def date_parts(attributes, attribute_name)
      [attributes["#{attribute_name}(1i)"],
       attributes["#{attribute_name}(2i)"],
       attributes["#{attribute_name}(3i)"]]
    end
  end

  class_methods do
    def clean_multiparameter_date_attributes(*date_attribute_names)
      define_method(:assign_attributes) do |new_attributes|
        clean_multiparameter_dates(new_attributes, date_attribute_names)
        super(new_attributes)
      end
    end
  end
end
