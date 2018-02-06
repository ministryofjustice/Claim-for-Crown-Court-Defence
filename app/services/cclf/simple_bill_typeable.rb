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
    def bill_type
      self.class.bill_type
    end

    def bill_subtype
      self.class.bill_subtype
    end
  end
end
