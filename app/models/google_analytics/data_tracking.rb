module GoogleAnalytics
  class DataTracking
    cattr_accessor :adapter, :adapter_name

    class << self
      def enabled?
        adapter.present? && Rails.env.production? && (Rails.host.staging? || Rails.host.gamma?)
      end

      def track(*args)
        if enabled?
          raise ArgumentError, 'Uninitialized adapter' unless adapter
          adapter.new(*args)
        end
      end

      def adapter=(name)
        @@adapter_name, @@adapter = name, "GoogleAnalytics::#{name.upcase}DataAdapter".constantize
      end
    end

    private_class_method :new
  end
end
