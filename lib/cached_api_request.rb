require 'caching'
require 'digest/sha1'

class CachedApiRequest
  attr_accessor :url

  VERSION = 1 # cache version, not necessarily matching API version

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
    if new_record? || created_at < cache_policy.call
      puts "caching response for url: #{url}"
      Caching.set(policy_key, Time.zone.now.to_s)
      Caching.set(cache_key, yield)
    else
      puts "reading response for url: #{url}"
    end
    content
  end


  private

  def url_digest
    @url_digest ||= Digest::SHA1.hexdigest(url)
  end

  def cache_key
    "api:#{version}:#{url_digest}"
  end

  def policy_key
    "api:#{version}:#{url_digest}:created_at"
  end

  def version
    VERSION
  end

  def content
    Caching.get(cache_key)
  end

  def created_at
    Time.zone.parse(Caching.get(policy_key)) rescue nil
  end

  def new_record?
    content.nil? || created_at.nil?
  end
end
