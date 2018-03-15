module TransferBrainDelegatable
  extend ActiveSupport::Concern

  class_methods do
    def transfer_brain_delegate(*method_names)
      method_names.each do |method_name|
        define_method(method_name) do
          Claim::TransferBrain.__send__(method_name.to_sym, self)
        end
      end
    end
  end
end
