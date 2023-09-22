# This file is used by Rack-based servers to start the application.

if %w(production devunicorn).include?(ENV['RAILS_ENV']) && ENV['ENV']
  require 'unicorn/worker_killer'
  require_relative 'lib/host_memory'

  min = HostMemory.percentage_of_total(8).to_i
  max = HostMemory.percentage_of_total(11).to_i
  puts "Unicorn worker: memory limits calculated at between #{min} and #{max}KB"
  oom_min = ([min/1024, 180].compact.max * (1024**2))
  oom_max = ([max/1024, 240].compact.max * (1024**2))
  puts "Unicorn worker: respawn when memory between #{oom_min/(1024**2)} and #{oom_max/(1024**2)}MB"
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end

require_relative 'config/environment'
run Rails.application
Rails.application.load_server
