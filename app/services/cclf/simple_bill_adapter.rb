require_relative 'simple_bill_typeable'

module CCLF
  class SimpleBillAdapter < SimpleDelegator
    include SimpleBillTypeable
  end
end
