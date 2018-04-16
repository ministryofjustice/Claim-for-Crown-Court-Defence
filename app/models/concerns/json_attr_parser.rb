# Credit to https://github.com/rails/rails/issues/28292#issuecomment-324061067
module JsonAttrParser
  extend ActiveSupport::Concern

  included do
    columns.select { |column| column.type == :json }.map(&:name).each do |attr|
      define_method("#{attr}=") do |value|
        self[attr] = value.is_a?(String) ? JSON.parse(value) : value
      end
    end
  end
end
