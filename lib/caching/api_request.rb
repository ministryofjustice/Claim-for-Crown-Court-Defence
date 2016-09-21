require 'digest/sha1'
require 'uri'

module Caching
  class ApiRequest
    attr_accessor :url, :options

    # Cache version, not necessarily matching API version
    # Used for global invalidation when structure/data changes
    VERSION = 2

    DEFAULT_OPTIONS = {
      ttl: 900, # 15 minutes
      ignore_params: ['api_key']
    }.freeze

    class << self
      def cache(url, options = {})
        new(url, options).cache do
          yield if block_given?
        end
      end
    end

    def initialize(url, options = {})
      self.options = DEFAULT_OPTIONS.merge(options)
      self.url = processed_url(url)
    end

    def cache
      if content.nil? || stale?
        puts "caching response for url: #{url}"
        self.content = [timestamp, yield].join(';')
      else
        puts "reading response for url: #{url}"
      end
      data
    end

    def data
      parsed_content.last
    end

    def created_at
      Time.zone.at(parsed_content.first.to_i) rescue nil
    end

    def stale?
      created_at < ttl.seconds.ago
    end

    def ignore_params
      options[:ignore_params] || []
    end

    def ttl
      options[:ttl] || 0
    end


    private

    def digest
      Digest::SHA1.hexdigest(url)
    end

    def cache_key
      "api:#{VERSION}:#{digest}"
    end

    def content
      @content ||= Caching.get(cache_key)
    end

    def content=(value)
      @content = Caching.set(cache_key, value)
    end

    def parsed_content
      content.split(';', 2)
    end

    def timestamp
      Time.zone.now.to_i
    end

    def processed_url(url)
      uri = URI::parse(url.downcase)
      uri.query = filter_query(uri.query)
      uri.fragment = nil
      uri.to_s
    end

    def filter_query(query)
      return nil unless query.present?
      params = query.split('&').reject { |param| ignore_params.include?(param.split('=')[0]) }
      params.any? ? params.sort.join('&') : nil
    end
  end
end
