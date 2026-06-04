module Remote
  module SimpleAssociations
    extend ActiveSupport::Concern

    module ClassMethods
      def has_one(name, options = {})
        has_relationship(:one, name, options)
      end

      def has_many(name, options = {})
        has_relationship(:many, name, options)
      end

      private

      def has_relationship(kind, name, options)
        klass = options.fetch(:class_name, "Remote::#{name.to_s.classify}".constantize)

        define_method(:"#{name}=") do |attrs|
          instance_variable_set(:"@#{name}", kind == :one ? klass.new(attrs) : attrs.map { |e| klass.new(e) })
        end

        define_method(name) do
          instance_variable_get(:"@#{name}")
        end
      end
    end
  end
end
