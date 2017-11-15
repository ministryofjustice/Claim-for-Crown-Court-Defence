require 'chronic'

# https://github.com/ssoroka/scheduler_daemon
class PollInjectionResponsesTask < Scheduler::SchedulerTask
  environments :production, :demo
  every '1m'

  def run
    queue = Settings.aws.response_queue
    return unless queue
    log("Checking for messages on #{queue}")
    MessageQueue::AwsClient.new(queue).poll!
  rescue StandardError => ex
    log('There was an error: ' + ex.message)
  ensure
    log('Injection import complete')
  end
end
