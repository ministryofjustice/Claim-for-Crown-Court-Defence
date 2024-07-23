class CspReportsController < ApplicationController
  skip_load_and_authorize_resource only: %i[create]
  skip_forgery_protection

  def create
    # slack_notifier.build_payload(
    #   icon: ':security:',
    #   title: 'Content Security Policy violation',
    #   message: report.map { |key, value| "#{key}: #{value}" }.join("\n") + "\n\nUser agent: #{request.env['HTTP_USER_AGENT']}",
    #   status: :fail
    # )
    # slack_notifier.send_message

    head :ok
  end

  private

  def slack_notifier
    @slack_notifier ||= SlackNotifier.new(
      'laa-cccd-alerts',
      formatter: SlackNotifier::Formatter::Generic.new,
      slack_bot_name: 'CSP'
    )
  end

  def report
    @report ||= JSON.parse(body)['csp-report']
  rescue JSON::ParserError
    @report ||= { error: 'Unable to parse data' }
  end

  def body = @body ||= request.body.read
end
