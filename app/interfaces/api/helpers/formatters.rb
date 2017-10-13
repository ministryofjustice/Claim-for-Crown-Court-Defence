module API::Helpers
  module Formatters
    extend Grape::API::Helpers

    Grape::Entity.format_with :utc do |date|
      unless date.nil?
        date.is_a?(Time) ? date.utc : date.strftime('%Y-%m-%d')
      end
    end

    Grape::Entity.format_with(:string, &:to_s)

    Grape::Entity.format_with :decimal do |number|
      number.to_f.round(2)
    end

    Grape::Entity.format_with :bool_char do |boolean|
      boolean.to_s.true? ? 'Y' : 'N'
    end
  end
end
