# This file is used by Rack-based servers to start the application.
if %w(production devunicorn).include?(ENV['RAILS_ENV']) && ENV['ENV']
  require 'unicorn/worker_killer'
  require_relative 'lib/host_memory'

  min = HostMemory.percentage_of_total(8).to_i
  max = HostMemory.percentage_of_total(11).to_i
  oom_min = [min/1024, 180].compact.max
  oom_max = [max/1024, 240].compact.max

  use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
