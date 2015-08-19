module NumberCommaParser
  extend ActiveSupport::Concern

  module ClassMethods
    def numeric_attributes(*attributes)
      attributes.each do |attribute|
        define_method("#{attribute}=") do |value|
          value.is_a?(String) ? self[attribute] = value.gsub(',', '') : self[attribute] = value
        end
      end
    end
  end
end
