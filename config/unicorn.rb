worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 90


if ENV["RAILS_ENV"] == 'production'
  timeout 15
  preload_app true

  # log to specific files, otherwise these default to /dev/null
  stderr_path '/srv/tribunals/log/unicorn.stderr.log'
  stdout_path '/srv/tribunals/log/unicorn.stdout.log'

  before_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
      Process.kill 'QUIT', Process.pid
    end

    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
  end

  after_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
    end

    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
  end
end

