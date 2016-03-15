namespace :scheduler do

  desc 'Starts the scheduler daemon in console mode'
  task :run do
    sh 'bundle exec scheduler_daemon run'
  end

  desc 'Starts the scheduler daemon'
  task :start do
    sh 'bundle exec scheduler_daemon start'
  end

  desc 'Stops the scheduler daemon'
  task :stop do
    sh 'bundle exec scheduler_daemon stop'
  end

  desc 'Restarts the scheduler daemon'
  task :restart do
    sh 'bundle exec scheduler_daemon restart'
  end

end
