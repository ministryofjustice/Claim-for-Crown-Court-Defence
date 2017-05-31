module NumberCommaParser
  extend ActiveSupport::Concern

  module ClassMethods
    def numeric_attributes(*attributes)
      attributes.each do |attribute|
        define_method("#{attribute}=") do |value|
          self[attribute] = value.is_a?(String) ? value.delete(',') : value
        end
      end
    end
  end
end
