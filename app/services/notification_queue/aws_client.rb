module NotificationQueue
  class AwsClient
    def send!(claim)
      client = Aws::SNS::Client.new(access_key_id: Settings.aws.access, secret_access_key: Settings.aws.secret)
      arn = Settings.aws.submitted_topic_arn
      message = NotificationQueue::MessageTemplate.for_claim(arn, claim)
      client.publish(message)
      true
    end
  end
end
