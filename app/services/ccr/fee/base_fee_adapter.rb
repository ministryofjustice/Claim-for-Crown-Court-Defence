module CCR
  module Fee
    class BaseFeeAdapter
      KEYS = %i[bill_type bill_subtype].freeze

      attr_reader :object
      attr_reader :mappings

      delegate :bill_type, :bill_subtype, to: :@bill_types

      def self.zip(bill_types = [])
        Hash[KEYS.zip(bill_types)]
      end

      def initialize
        @mappings = bill_mappings
      end

      def call(object)
        @object = object
        @bill_types = OpenStruct.new(mappings[bill_key])
      end

      private

      def bill_mappings
        raise 'Implement in sub-class'
      end

      def bill_key
        raise 'Implement in sub-class'
      end
    end
  end
end
