module GoogleAnalytics
  class DataTracking
    cattr_accessor :adapter, :adapter_name, :usage_name

    class << self
      def enabled?
        usage_name && adapter.present? && Rails.env.production?
      end

      def analytics?
        enabled? && adapter_name.eql?(:ga)
      end

      def track(*)
        return unless enabled?
        raise ArgumentError, 'Uninitialized adapter' unless adapter
        adapter.new(*)
      end

      def adapter=(name)
        @@adapter_name = name
        @@adapter = "GoogleAnalytics::#{name.upcase}DataAdapter".constantize
      end
    end

    private_class_method :new
  end
end
