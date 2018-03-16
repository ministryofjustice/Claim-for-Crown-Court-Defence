module TransferDataItemDelegatable
  extend ActiveSupport::Concern

  class_methods do
    def data_item_delegate(*method_names)
      method_names.each do |method_name|
        define_method(method_name) do |detail|
          return unless detail_valid?(detail)
          data_item_for(detail)[method_name.to_sym]
        end
      end
    end
  end
end
