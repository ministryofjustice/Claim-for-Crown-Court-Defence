module NotificationQueue
  class AwsClient
    def send!(claim)
      client = Aws::SNS::Client.new(region: Settings.aws.region)
      arn = Settings.aws.sns.submitted_topic_arn
      message = NotificationQueue::MessageTemplate.for_claim(arn, claim)
      client.publish(message)
      true
    end
  end
end
