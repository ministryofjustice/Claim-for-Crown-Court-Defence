module NotificationQueue
  class AwsClient
    def send!(claim)
      client = Aws::SNS::Client.new(aws_credentials)
      arn = Settings.aws.sns.submitted_topic_arn
      message = NotificationQueue::MessageTemplate.for_claim(arn, claim)
      client.publish(message)
      true
    end

    private

    # rubocop:disable Metrics/AbcSize
    def aws_credentials
      return { region: Settings.aws.region } if !Settings.aws.sns.access || Settings.aws.sns.access.include?('actual')

      # TODO: Remove when IRSA is used in all environments
      {
        access_key_id: Settings.aws.sns.access,
        secret_access_key: Settings.aws.sns.secret,
        region: Settings.aws.region
      }
    end
    # rubocop:enable Metrics/AbcSize
  end
end
