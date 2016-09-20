require 'caching'
require 'digest/sha1'

class CachedApiRequest
  attr_accessor :url

  # Cache version, not necessarily matching API version
  # Used for global invalidation when structure/data changes
  VERSION = 2

  class << self
    def cache(url, cache_policy = -> { 15.minutes.ago })
      new(url).cache(cache_policy) do
        yield if block_given?
      end
    end
  end

  def initialize(url)
    self.url = url
  end

  def cache(cache_policy)
    if content.nil? || created_at < cache_policy.call
      puts "caching response for url: #{url}"
      self.content = [timestamp, yield].join(';')
    else
      puts "reading response for url: #{url}"
    end
    data
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

  def data
    parsed_content.last
  end

  def created_at
    Time.zone.at(parsed_content.first.to_i) rescue nil
  end

  def timestamp
    Time.zone.now.to_i
  end
end
