module API::Helpers
  module Formatters
    extend Grape::API::Helpers

    Grape::Entity.format_with :utc do |date|
      unless date.nil?
        date.is_a?(Date) ? date.to_time(:utc) : date.utc
      end
    end

    Grape::Entity.format_with :decimal do |number|
      number.to_f.round(2)
    end
  end
end
