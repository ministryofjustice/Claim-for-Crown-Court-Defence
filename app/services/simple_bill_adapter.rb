require_relative 'simple_bill_typeable'

class SimpleBillAdapter < SimpleDelegator
  include SimpleBillTypeable
end
