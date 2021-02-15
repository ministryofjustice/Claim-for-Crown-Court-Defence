require 'digest/sha1'
require 'uri'

class Caching
  class ApiRequest
    attr_accessor :url, :options

    # Cache version, not necessarily matching API version
    # Used for global invalidation when structure/data changes
    VERSION = 3

    DEFAULT_OPTIONS = {
      ttl: 900, # 15 minutes
      ignore_params: []
    }.freeze

    def initialize(url, options = {})
      self.options = DEFAULT_OPTIONS.merge(options)
      self.url = processed_url(url)
    end

    def self.cache(url, options = {}, &block)
      new(url, options).cache(&block)
    end

    def cache
      save! Caching::Response.new(yield) if (content.nil? || stale?) && block_given?
      data
    end

    def created_at
      content_parts[0].to_i
    end

    def max_age
      content_parts[1].to_i
    end

    def data
      content_parts[2]
    end

    def stale?
      now > (created_at + max_age)
    end

    def ignore_params
      options[:ignore_params] || []
    end

    def default_ttl
      options[:ttl].to_i
    end

    private

    def digest
      Digest::SHA1.hexdigest(url)
    end

    def cache_key
      "api:#{VERSION}:#{digest}"
    end

    def now
      Time.zone.now.to_i
    end

    def content
      @content ||= Caching.get(cache_key)
    end

    def save!(response)
      ttl = (response.ttl || default_ttl).to_i
      body = response.body
      payload = [now, ttl, body].join(';')

      @content = ttl.zero? ? payload : Caching.set(cache_key, payload)
    end

    def content_parts
      content.to_s.split(';', 3)
    end

    def processed_url(url)
      uri = URI.parse(url.downcase)
      uri.query = filter_query(uri.query)
      uri.fragment = nil
      uri.to_s
    end

    def filter_query(query)
      return if query.blank?
      params = query.split('&').reject { |param| ignore_params.include?(param.split('=')[0]) }
      params.any? ? params.sort.join('&') : nil
    end
  end
end
