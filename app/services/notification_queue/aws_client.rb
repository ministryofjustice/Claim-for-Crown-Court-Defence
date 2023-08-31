module NotificationQueue
  class AwsClient
    def send!(claim)
      client = Aws::SNS::Client.new(
        access_key_id: Settings.aws.sns.access,
        secret_access_key: Settings.aws.sns.secret,
        region: Settings.aws.region
      )
      arn = Settings.aws.sns.submitted_topic_arn
      message = NotificationQueue::MessageTemplate.for_claim(arn, claim)
      client.publish(message)
      true
    end

    private

    def aws_credentials
      return { region: Settings.aws.region } unless Settings.aws.sns.access

      # TODO: Remove when IRSA is used in all environments
      {
        access_key_id: Settings.aws.sns.access,
        secret_access_key: Settings.aws.sns.secret,
        region: Settings.aws.region
      }
    end
  end
end
