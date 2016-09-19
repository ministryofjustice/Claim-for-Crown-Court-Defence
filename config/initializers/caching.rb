require 'caching'
require 'memory_caching'

# REDIS_URL env variable will be used automatically if set,
# otherwise, default will be 'redis://127.0.0.1:6379'
#
# Caching.backend = Redis.current
Caching.backend = MemoryCaching.current
