module API::Helpers
  module Formatters
    extend Grape::API::Helpers

    Grape::Entity.format_with :utc do |date|
      date&.utc
    end

    Grape::Entity.format_with :decimal do |number|
      number&.to_f
    end
  end
end
