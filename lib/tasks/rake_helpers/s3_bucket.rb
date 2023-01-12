# frozen_string_literal: true

require 'aws-sdk-s3'

Credentials = Struct.new(:access_key_id, :secret_access_key, :bucket)

class S3Bucket
  def initialize(host)
    @host = host
  end

  attr_reader :host

  def put_object(key, body)
    client.put_object({
      bucket: credentials.bucket,
      key: key,
      acl: 'private',
      body: body
    })
  end

  def get_object(key, **args)
    client.get_object(
      {bucket: credentials.bucket, key: key},
      **args
    )
  end

  def list(folder_prefix = nil)
    bucket.objects({prefix: folder_prefix})
  end

  def bucket
     @bucket ||= Aws::S3::Bucket.new(credentials.bucket, { client: client })
  end

  def client
    @client ||= Aws::S3::Client.new(
      access_key_id: credentials.access_key_id,
      secret_access_key: credentials.secret_access_key
    )
  end

  private

  # For remote we can just use Settings file, for local we need to use specified host
  # secrets, which requires kubectl.
  def credentials
    return @credentials if @credentials

    Rails.env.development? ? load_from_secrets : load_from_settings
  end

  def load_from_settings
    @credentials ||= Credentials.new(
                   Settings.aws.s3.access,
                   Settings.aws.s3.secret,
                   Settings.aws.s3.bucket
                 )
  end

  def load_from_secrets
    secrets = YAML.safe_load(`#{s3_secrets_cmd}`.chomp)
    secrets['data'].transform_values! { |v| Base64.decode64(v) unless v.nil? }
    @credentials ||= Credentials.new(
                       secrets['data']['access_key_id'],
                       secrets['data']['secret_access_key'],
                       secrets['data']['bucket_name']
                     )
  rescue StandardError => e
    raise StandardError, "error retrieving secrets. do you have access?: #{e.message}"
  end

  def s3_secrets_cmd
    "kubectl --context live -n cccd-#{host} get secret cccd-s3-bucket -o yaml | grep -vE '#{grep_secret_excludes}'"
  end

  def grep_secret_excludes
    'annotations|last-applied-configuration|creationTimestamp|resourceVersion|selfLink|uid'
  end
end
