module TransferBrainDataItemCollectionDelegatable
  extend ActiveSupport::Concern

  class_methods do
    def data_item_collection_delegate(*method_names)
      method_names.each do |method_name|
        define_singleton_method(method_name) do |detail|
          Claim::TransferBrainDataItemCollection.instance.send(method_name.to_sym, detail)
        end
      end
    end
  end
end
