# frozen_string_literal: true

require 'aws-sdk-s3'

module Tasks
  module RakeHelpers
    class S3Bucket
      def initialize(host)
        @host = host
      end

      attr_reader :host

      def put_object(key, body)
        client.put_object({
          bucket: bucket_name,
          key: key,
          acl: 'private',
          body: body
        })
      end

      def get_object(key, **args)
        client.get_object(
          {bucket: bucket_name, key: key},
          **args
        )
      end

      def list(folder_prefix = nil)
        bucket.objects({prefix: folder_prefix})
      end

      def bucket
        @bucket ||= Aws::S3::Bucket.new(bucket_name, { client: client })
      end

      def client
        @client ||= Aws::S3::Client.new
      end

      private

      # For remote we can just use Settings file, for local we need to use specified host
      # secrets, which requires kubectl.
      def bucket_name
        return @bucket_name if @bucket_name

        Rails.env.development? ? load_from_secrets : load_from_settings
      end

      def load_from_settings
        @bucket_name ||= Settings.aws.s3.bucket
      end

      def load_from_secrets
        secrets = YAML.safe_load(`#{s3_secrets_cmd}`.chomp)
        secrets['data'].transform_values! { |v| Base64.decode64(v) unless v.nil? }
        @bucket_name ||= secrets['data']['bucket_name']
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
  end
end
