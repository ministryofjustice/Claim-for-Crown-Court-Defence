require 'optparse'
require 'notifications/client'

# rubocop:disable all
class EmailNotificationCLI
  TEMPLATE_ID = '9661d08a-486d-4c67-865e-ad976f17871d'.freeze

  def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
    @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    @rake_task, _ = @argv.shift(2)
  end

  def execute!
    parse_options!

    notification = client.send_email(payload)
    puts 'Email notification sent. ID: %s' % notification.id

    @kernel.exit(0)
  rescue Notifications::Client::RequestError => rex
    puts 'Request error. Code: %s, Message: %s' % [rex.code, rex.message]
    @kernel.exit(1)
  rescue => ex
    puts ex.message
    @kernel.exit(1)
  end


  private

  def client
    Notifications::Client.new(service_id, secret_key)
  end

  def template_id; @options.fetch(:template_id); end
  def service_id; @options.fetch(:service_id); end
  def secret_key; @options.fetch(:secret_key); end
  def recipient; @options.fetch(:recipient); end
  def personalisation; @options.fetch(:personalisation); end

  def payload
    {
      to: recipient,
      template: template_id,
      personalisation: personalisation
    }.to_json
  end

  def parse_options!
    # The following personalisation is for the default provided template_id
    # If you use a different template_id, make sure to provide in the command line
    # the proper personalisation, encoded in JSON format. Example:
    # --personalisation "{\"name\":\"test\",\"visit_url\":\"https://test.com\"}"
    #
    @options = {
        service_id: ENV['GOVUK_NOTIFY_SERVICE_ID'],
        secret_key: ENV['GOVUK_NOTIFY_API_SECRET'],
        template_id: TEMPLATE_ID,
        personalisation: {
            full_name: 'Full Name',
            messages_url: 'https://url.for.messages'
        }
    }

    parse_cli_arguments!

    unless @options[:service_id]
      print_help('--service-id 7832a6fc-39c6-430a-9a51-30395d05f4ed',
                 'A service ID needs to be provided, unless GOVUK_NOTIFY_SERVICE_ID env variable is set')
    end

    unless @options[:secret_key]
      print_help('--secret-key 7832a6fc-39c6-430a-9a51-30395d05f4ed',
                 'A secret key needs to be provided, unless GOVUK_NOTIFY_API_SECRET env variable is set')
    end

    unless @options[:recipient]
      print_help('--recipient email@digital.justice.gov.uk',
                 'A recipient email needs to be provided')
    end
  end

  def parse_cli_arguments!
    OptionParser.new do |opts|
      opts.banner = 'Usage: rake %s -- [options]' % @rake_task

      opts.on('--service-id SERVICE_ID', 'Service ID') { |service_id| @options[:service_id] = service_id }
      opts.on('--template-id TEMPLATE_ID', 'Template ID') { |template_id| @options[:template_id] = template_id }
      opts.on('--secret-key SECRET_KEY', 'API secret key') { |secret_key| @options[:secret_key] = secret_key }
      opts.on('-e', '--recipient EMAIL', 'Recipient email') { |recipient| @options[:recipient] = recipient }
      opts.on('-p', '--personalisation JSON', 'JSON string with key-values') { |p| @options[:personalisation] = JSON.parse(p) }

      opts.on('-h', '--help', 'Prints this help') do
        puts opts
        @kernel.exit(0)
      end
    end.parse!
  end

  def print_help(command, message)
    puts message
    puts 'Example: rake %s -- %s' % [@rake_task, command]
    puts 'Use -h or --help for help'
    @kernel.exit(1)
  end
end
# rubocop:enable all