module ApiClient
  module V1
    module Create
      extend ApiClient::V1
      extend self

      def claims(data)
        send('advocates/claims', data)
      end

      def defendants(data)
        send('advocates/defendants', data)
      end

      def fees(data)
        send('advocates/fees', data)
      end

      def expenses(data)
        send('advocates/expenses', data)
      end

      def dates_attended(data)
        send('advocates/dates_attended', data)
      end

      def representation_orders(data)
        send('advocates/representation_orders', data)
      end
    end
  end
end