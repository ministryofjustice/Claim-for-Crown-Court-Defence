module PerformancePlatform
  class UrlBuilder
    class << self
      def for_type(type)
        [PerformancePlatform.configuration.root_url, PerformancePlatform.configuration.group, type].join('/')
      end
    end
  end
end
