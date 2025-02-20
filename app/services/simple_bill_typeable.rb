module SimpleBillTypeable
  extend ActiveSupport::Concern

  class_methods do
    def acts_as_simple_bill(options = {})
      cattr_accessor :bill_type
      cattr_accessor :bill_subtype

      self.bill_type = options[:bill_type]
      self.bill_subtype = options[:bill_subtype]
    end
  end

  included do
    delegate :bill_type, to: :class
    delegate :bill_subtype, to: :class
  end
end
