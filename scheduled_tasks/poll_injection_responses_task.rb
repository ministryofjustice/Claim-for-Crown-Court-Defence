require 'chronic'

# https://github.com/ssoroka/scheduler_daemon
class PollInjectionResponsesTask < Scheduler::SchedulerTask
  environments :production, :demo
  every '1m'

  def run
    queue = Settings.aws.sqs.response_queue_url || Settings.aws.response_queue
    return unless queue
    log("Checking for messages on #{queue}")
    MessageQueue::AwsClient.new(queue).poll!
  rescue StandardError => e
    log('There was an error: ' + e.message)
  ensure
    log('Injection import complete')
  end
end
