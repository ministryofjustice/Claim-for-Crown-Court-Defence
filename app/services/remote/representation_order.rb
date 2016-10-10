module Remote
  class RepresentationOrder < Base
    attr_accessor :maat_reference, :date

    alias representation_order_date date
  end
end
