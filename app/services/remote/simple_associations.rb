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
        assignment = kind == :one ? "#{klass}.new(attrs)" : "attrs.map { |e| #{klass}.new(e) }"

        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{name}=(attrs); @#{name} = #{assignment}; end
          def #{name}; @#{name}; end
        CODE
      end
    end
  end
end
