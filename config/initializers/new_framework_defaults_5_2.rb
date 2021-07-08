# config.active_support.hash_digest_class allows configuring the digest class
# to use to generate non-sensitive digests, such as the ETag header.
Rails.application.config.active_support.hash_digest_class = OpenSSL::Digest::SHA1
