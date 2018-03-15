module TransferDataItemDelegatable
  extend ActiveSupport::Concern

  # TODO: Remove error raising as tt does not appear that the error raised is used anywhere.
  #
  class InvalidCombinationError < ArgumentError
    DEFAULT_MSG = 'Invalid combination of transfer detail fields'.freeze

    def initialize(msg = DEFAULT_MSG)
      super(msg)
    end
  end

  class_methods do
    def data_item_delegate(*method_names)
      method_names.each do |method_name|
        define_method(method_name) do |detail|
          raise InvalidCombinationError unless detail_valid?(detail)
          data_item_for(detail)[method_name.to_sym]
        end
      end
    end
  end
end
