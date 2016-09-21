Dir[File.join(Rails.root, 'lib', 'caching', '*.rb')].each { |file| require file }

# REDIS_URL env variable will be used automatically if set,
# otherwise, default will be 'redis://127.0.0.1:6379'
#
Caching.backend = if Rails.env.production?
                    Caching::RedisStore
                  else
                    Caching::MemoryStore
                  end
