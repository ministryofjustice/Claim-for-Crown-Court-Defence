module SimpleBillTypeable
  extend ActiveSupport::Concern

  class_methods do
    def acts_as_simple_bill(options = {})
      cattr_accessor :bill_type
      cattr_accessor :bill_subtype
      cattr_accessor :vat_included

      self.bill_type = options[:bill_type]
      self.bill_subtype = options[:bill_subtype]
      self.vat_included = options[:vat_included] || false
    end
  end

  included do
    def bill_type
      self.class.bill_type
    end

    def bill_subtype
      self.class.bill_subtype
    end

    def vat_included
      self.class.vat_included
    end
  end
end
