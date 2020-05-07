# Rake tasks to help with output to logs and console
#
# examples
# $ rake stdout db:seed:case_stages
# $ rake debug db:seed:case_stages
# $ rake info db:seed:case_stages
# $ rake warn db:seed:case_stages
# $ rake error db:seed:case_stages
#
desc 'Redirect logging to stdout. prefix other tasks with this task to use'
task :stdout => [:environment] do
  Rails.logger = Logger.new(STDOUT)
end

desc 'Set logging to debug level. prefix other tasks with this task to use'
task :debug => [:environment, :stdout] do
  Rails.logger.level = Logger::DEBUG
end

desc 'Set logging to info level. prefix other tasks with this task to use'
task :info => [:environment, :stdout] do
  Rails.logger = Logger.new(STDOUT)
end

desc 'Set logging to debug level. prefix other tasks with this task to use'
task :warn => [:environment, :stdout] do
  Rails.logger.level = Logger::WARN
end

desc 'Set logging to error level. prefix other tasks with this task to use'
task :error => [:environment, :stdout] do
  Rails.logger.level = Logger::WARN
end
