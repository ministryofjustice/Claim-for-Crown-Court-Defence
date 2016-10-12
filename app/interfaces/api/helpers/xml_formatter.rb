module API::Helpers
  module XMLFormatter

    class << self
      def call(object, _env)
        return xml_format(object) if object.respond_to?(:to_xml)
        raise Grape::Exceptions::InvalidFormatter.new(object.class, 'xml')
      end

      private

      def xml_format(object)
        if object.is_a?(Hash)
          root = object.keys.first
          object[root].to_xml(default_options.merge(root: root))
        else
          object.to_xml(default_options)
        end
      end

      def default_options
        {dasherize: false, skip_types: true, root: 'resource'}
      end
    end

  end
end
