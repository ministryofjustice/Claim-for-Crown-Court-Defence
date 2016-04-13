namespace :old_cukes do

  desc 'run all the old cukes in one process'
  task :cuke do
    command = %x{which cucumber}.chomp
    cuke_dir = File.join(Rails.root, 'old_features')
    cmd = "#{command} #{cuke_dir} --require old_features/step_definitions/ --require old_features/support/"
    system cmd
  end
end

