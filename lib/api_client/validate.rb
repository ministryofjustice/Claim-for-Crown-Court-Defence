module ApiClient
  module Validate
    extend ApiClient
    extend self

    def claims(data)
      send('advocates/claims/validate', data)
    end

    def defendants(data)
      send('advocates/defendants/validate', data)
    end

    def fees(data)
      send('advocates/fees/validate', data)
    end

    def expenses(data)
      send('advocates/expenses/validate', data)
    end

    def dates_attended(data)
      send('advocates/dates_attended/validate', data)
    end

    def representation_orders(data)
      send('advocates/representation_orders/validate', data)
    end
  end
end