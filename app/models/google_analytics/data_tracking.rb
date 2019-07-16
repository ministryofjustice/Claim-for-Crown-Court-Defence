module GoogleAnalytics
  class DataTracking
    cattr_accessor :adapter, :adapter_name

    class << self
      def enabled?
        adapter.present? && Rails.env.production?
      end

      def tag_manager?
        enabled? && adapter_name.eql?(:gtm)
      end

      def analytics?
        enabled? && adapter_name.eql?(:ga)
      end

      def track(*args)
        return unless enabled?
        raise ArgumentError, 'Uninitialized adapter' unless adapter
        adapter.new(*args)
      end

      def adapter=(name)
        @@adapter_name = name
        @@adapter = "GoogleAnalytics::#{name.upcase}DataAdapter".constantize
      end
    end

    private_class_method :new
  end
end
