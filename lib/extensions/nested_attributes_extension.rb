module NestedAttributesExtension
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def all_blank_or_zero
      ->(attributes) { attributes.all? { |key, value| key == '_destroy' || (value.blank? || value.zero?) } }
    end
  end
end
