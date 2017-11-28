# This file is used by Rack-based servers to start the application.
if ENV["RAILS_ENV"].in?(['production','devunicorn'])
  # Unicorn self-process killer
  require 'unicorn/worker_killer'

  # Max memory size (RSS) per worker
  oom_min = (192) * (1024**2)
  oom_max = (256) * (1024**2)
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
